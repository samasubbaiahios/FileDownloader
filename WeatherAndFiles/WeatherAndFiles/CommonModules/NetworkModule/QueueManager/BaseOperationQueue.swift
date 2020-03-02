//
//  BaseOperationQueue.swift
//  FileDownloaderApp
//
//  Created by Venkata Subbaiah Sama on 24/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation

protocol OperationQueueProtocol: NSObjectProtocol {
    func operationQueue(_ operationQueue: BaseOperationQueue, didFinishOperation operation: Operation, with errors: [Error])
    func operationQueue(_ operationQueue: BaseOperationQueue, willAddOperation operation: Operation)
}

struct SimpleBlockObserver: OperationObserver {
    
    private let opBeginCallback: ((BaseAsyncOperation) -> Void)?
    private let opProduceCallback: ((BaseAsyncOperation, BaseAsyncOperation) -> Void)?
    private let opFinishCallback: ((BaseAsyncOperation, [Error]) -> Void)?
    
    init(opBeginCallback: ((BaseAsyncOperation) -> Void)?=nil, opProduceCallback: ((BaseAsyncOperation, BaseAsyncOperation) -> Void)? = nil, opFinishCallback: ((BaseAsyncOperation, [Error]) -> Void)? = nil) {
        self.opBeginCallback = opBeginCallback
        self.opProduceCallback = opProduceCallback
        self.opFinishCallback = opFinishCallback
    }
    
    // MARK: OperationObserverProtocol
    
    func operationWillStart(_ operation: BaseAsyncOperation) {
        print("operationWillStart invoked")
    }
    
    func operationDidStart(_ operation: BaseAsyncOperation) {
        opBeginCallback?(operation)
    }
    
    func operation(_ operation: BaseAsyncOperation, didProduceOperation newOperation: BaseAsyncOperation) {
        opProduceCallback?(operation, newOperation)
    }
    
    func operationWillFinish(_ operation: BaseAsyncOperation) {
        print("operationWillFinish invoked")
    }
    
    func operationDidFinish(_ operation: BaseAsyncOperation, with errors: [Error]) {
        //        DPrint("operation.name=\(String(describing: operation.name)) is finished")
        opFinishCallback?(operation, errors)
    }
}

class BaseOperationQueue: OperationQueue {
    weak var queueDelegate: OperationQueueProtocol?
    
    override func addOperation(_ op: Operation) {
        if let baseOperation = op as? BaseAsyncOperation {
            let blockObserver = SimpleBlockObserver(
                opProduceCallback: { [weak self] in
                    self?.addOperation($1) // 2nd param is newOperation
                },
                opFinishCallback: { [weak self] in
                    if let queue = self {
                        queue.queueDelegate?.operationQueue(queue, didFinishOperation: $0, with: $1)
                    }
                }
            )
            
            baseOperation.addObserver(blockObserver)
            baseOperation.willEnqueue()
        } else {
            // regular Operation
            op.completionBlock = {
                [weak self, weak op] in
                guard let queue = self, let baseOp = op else { return }
                queue.queueDelegate?.operationQueue(queue, didFinishOperation: baseOp, with: [])
            }
        }
        
        queueDelegate?.operationQueue(self, willAddOperation: op)
        super.addOperation(op)
    }
    
    override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        for op in ops {
            addOperation(op)
        }
        
        if wait {
            for op in ops {
                op.waitUntilFinished()
            }
        }
    }
}

protocol OperationObserver {
    func operationWillStart(_ operation: BaseAsyncOperation)
    func operationDidStart(_ operation: BaseAsyncOperation)
    
    func operation(_ operation: BaseAsyncOperation, didProduceOperation otherOperation: BaseAsyncOperation)
    
    func operationWillFinish(_ operation: BaseAsyncOperation)
    func operationDidFinish(_ operation: BaseAsyncOperation, with errors: [Error])
}


class BaseAsyncOperation: Operation {
    fileprivate var _internalErrors = [Error]()
    var operationLinkingId: String = ""
    private(set) var observers = [OperationObserver]()
    
    override final func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        
        for observer in observers {
            observer.operationDidStart(self)
        }
        execute()
    }
    
    func execute() {
        print("subclass '\(type (of: self))' must override execute method, default implementation will finish this operation")
    }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished || _cancelled
    }
    
    private var _cancelled = false {
        willSet {
            willChangeValue(forKey: "isCancelled")
        }
        didSet {
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    override var isCancelled: Bool {
        return _cancelled
    }
    
    func cancelled(_ wasCencelled: Bool) {
        _cancelled = wasCencelled
    }
    
    func executing(_ executing: Bool) {
        _executing = executing
    }
    
    func finish(_ finished: Bool) {
        executing(false)
        _finished = finished
    }
    
    final func finish(with errors: [Error] = []) {
        if !_finished {
            _internalErrors += errors
            
            finished(with: _internalErrors)
            
            //notify all the observers about finished state
            for observer in observers {
                observer.operationDidFinish(self, with: _internalErrors)
            }
        }
    }
    
    func finished(with errors: [Error]) {
        finish(true)
    }
    
    override func cancel() {
        super.cancel()
        self.cancelled(true)
        if self.isExecuting {
            self.finish(true)
        }
    }
    
    func cancel(with error: Error? = nil) {
        if let opError = error {
            _internalErrors.append(opError)
        }
        cancel()
    }
    
    func willEnqueue() {
    }
    
    func addObserver(_ observer: OperationObserver) {
        observers.append(observer)
    }
    
    var errors: [Error]? {
        return _internalErrors
    }
    
}

class BaseGroupOperation: BaseAsyncOperation {
    private let internalQueue = BaseOperationQueue()
    
    fileprivate var combinedErrors = [Error]()
    
    private let firstOperation = BlockOperation(block: {})
    private let lastOperation = BlockOperation(block: {})
    
    convenience init(ops: Operation...) {
        self.init(ops: ops)
    }
    
    init(ops: [Operation]) {
        super.init()
        setupQueue(ops)
    }
    
    var operations: [Operation] {
        return internalQueue.operations
    }
    
    override func execute() {
        internalQueue.isSuspended = false
        internalQueue.addOperation(lastOperation)
    }
    
    func operationDidFinish(_ operation: Operation, with errors: [Error]) {
        // subclass should implement
        combinedErrors += errors
    }
}

extension BaseGroupOperation {
    private func setupQueue(_ ops: [Operation]) {
        internalQueue.queueDelegate = self
        internalQueue.isSuspended = true
        internalQueue.addOperation(firstOperation)
        for op in ops {
            internalQueue.addOperation(op)
        }
    }
    
    func add(_ operation: Operation) {
        internalQueue.addOperation(operation)
    }
    
    override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
    
    final func combine(_ error: Error) {
        combinedErrors.append(error)
    }
}

extension BaseGroupOperation: OperationQueueProtocol {
    final func operationQueue(_ operationQueue: BaseOperationQueue, didFinishOperation operation: Operation, with errors: [Error]) {
        if operation === lastOperation {
            internalQueue.isSuspended = true
            finish(with: combinedErrors)
        } else if operation !== firstOperation {
            operationDidFinish(operation, with: errors)
        }
    }
    
    final func operationQueue(_ operationQueue: BaseOperationQueue, willAddOperation operation: Operation) {
        assert(!lastOperation.isFinished && !lastOperation.isExecuting, "Cannot add operation to group after its done executing all the operations")
        
        if operation !== lastOperation {
            lastOperation.addDependency(operation)
        }
        
        if operation !== firstOperation {
            operation.addDependency(firstOperation)
        }
    }
    
}

extension BlockOperation {
    static func withDepencies(_ dependencies: [Operation], completionBlock: @escaping () -> Void) -> BlockOperation {
        let op = BlockOperation(block: completionBlock)
        
        for dependencyOp in dependencies {
            op.addDependency(dependencyOp)
        }
        
        return op
    }
}

