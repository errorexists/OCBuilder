//
//  TaskViewController.swift
//  OCBuilder
//
//  Created by Pavo on 7/27/19.
//  Copyright © 2019 Pavo. All rights reserved.
//

import Cocoa

class TaskViewController: NSViewController {
    
    @IBOutlet var pathLocation: NSPathControl!
    @IBOutlet var spinner: NSProgressIndicator!
    @IBOutlet var outputText: NSTextView!
    @IBOutlet var buildButton: NSButton!
    @IBOutlet var cloneLocation: NSPathControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.isHidden = true
        
    }
    
    @objc dynamic var isRunning = false
    var outputPipe:Pipe!
    var buildTask:Process!
    
    @IBAction func startTask(_ sender: Any) {
        spinner.isHidden = false
        outputText.string = ""
        
        if let cloneURL = cloneLocation.url, let repositoryURL = pathLocation.url {
            
            let cloneLocation = cloneURL.path
            let finalLocation = repositoryURL.path
            let nasm = "/usr/local/bin/nasm"
            let mtoc = "/usr/local/bin/mtoc"
            
            guard let nasmPath = Bundle.main.path(forResource: "nasm", ofType: "") else {
                print("Unable to locate nasm")
                return
            }
            
            guard let mtocPath = Bundle.main.path(forResource: "mtoc", ofType: "") else {
                print("Unable to locate mtoc")
                return
            }
            
            var arguments:[String] = []
            arguments.append(cloneLocation)
            arguments.append(finalLocation)
            arguments.append(nasm)
            arguments.append(mtoc)
            arguments.append(nasmPath)
            arguments.append(mtocPath)
           
            buildButton.isEnabled = false
            spinner.startAnimation(self)
            runScript(arguments)
            
        }
        
    }
    
    
    @IBAction func stopTask(_ sender: Any) {
        spinner.isHidden = true
        if isRunning {
            buildTask.terminate()
        }
    }
    
    func runScript(_ arguments:[String]) {
        
        isRunning = true
        
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        taskQueue.async {
            
            guard let path = Bundle.main.path(forResource: "BuildScript",ofType:"command") else {
                print("Unable to locate BuildScript.command")
                return
            }
            
            self.buildTask = Process()
            self.buildTask.launchPath = path
            self.buildTask.arguments = arguments
            self.buildTask.terminationHandler = {
                
                task in
                DispatchQueue.main.async(execute: {
                    self.buildButton.isEnabled = true
                    self.spinner.stopAnimation(self)
                    self.isRunning = false
                })
                
            }
            
            self.captureStandardOutputAndRouteToTextView(self.buildTask)
            self.buildTask.launch()
            self.buildTask.waitUntilExit()
            
        }
        
    }
    
    func captureStandardOutputAndRouteToTextView(_ task:Process) {
        
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            DispatchQueue.main.async(execute: {
                let previousOutput = self.outputText.string
                let nextOutput = previousOutput + "\n" + outputString
                self.outputText.string = nextOutput
                
                let range = NSRange(location:nextOutput.count,length:0)
                self.outputText.scrollRangeToVisible(range)
                
            })
            
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            
        }
        
    }
    
}
