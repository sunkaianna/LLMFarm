//
//  Model.swift
//  Mia
//
//  Created by Byron Everson on 12/25/22.
//

import Foundation
enum ModelInference {
    case LLamaInference
    case GPTNeoxInference
}

class AI {
    
    var aiQueue = DispatchQueue(label: "Mia-Main", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    //var model: Model!
    var model: Model!
    var modelPath: String
    var modelName: String
    var chatName: String
    
    var flagExit = false
    private(set) var flagResponding = false
    
    init(_modelPath: String,_chatName: String) {
        self.modelPath = _modelPath
        self.modelName = NSURL(fileURLWithPath: _modelPath).lastPathComponent!
        self.chatName = _chatName
    }
    
    func loadModel(_ aiModel: ModelInference) {
        print("AI init")
        switch aiModel {
        case .LLamaInference:
            model = try? LLaMa(path: self.modelPath)
        case .GPTNeoxInference:
            model = try? GPTNeoX(path: self.modelPath)
        }
    }
    
    func text(_ input: String, _ maxOutputCount: Int = 2048, _ tokenCallback: ((String, Double) -> ())?, _ completion: ((String) -> ())?) {
        flagResponding = true
        aiQueue.async {
            func mainCallback(_ str: String, _ time: Double) -> Bool {
                DispatchQueue.main.async {
                    tokenCallback?(str, time)
                }
                if self.flagExit {
                    // Reset flag
                    self.flagExit = false
                    // Alert model of exit flag
                    return true
                }
                return false
            }
            guard let completion = completion else { return }
            
            // Model output
            let output = try? self.model.predict(input, mainCallback)
            
            DispatchQueue.main.async {
                self.flagResponding = false
                completion(output ?? "[Error]")
            }
        }
    }
    
    
}



