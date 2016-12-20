//
//  ViewController.swift
//  DynamicSwiftDemo
//
//  Created by AugustRush on 12/7/16.
//  Copyright © 2016 August. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swiftToJSTest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Test Methods

    func swiftToJSTest() {
        
        let path = Bundle.main.path(forResource: "Controller", ofType: "bis")
        
        do {
            let string = try String.init(contentsOfFile: path!, encoding: .utf8)
            print("file string is \(string)")
            let tokens = BSLexer.tokenlize(string)
            print("all tokens is \(tokens)")
            
            let parser = BSParser.init(tokens: tokens)
            let nodes = try parser.parseToASTNodes()
            print("all nodes is \(nodes)")
            
            let context = BSJavaScriptBridge.sharedInstance().context
            
            let classNode = nodes.first! as! BSClassNode
            classNode.exportToJS(InContext: context)
            
            
        } catch let err as NSError {
            print("error is \(err)")
        }
        
    }
    
    
    @IBAction func pushController(_ sender: Any) {
        // get instance

        let instance = BSInstance(ForClassName: "Controller") as? UIViewController
        print("instance is \(instance)")

        if let controller = instance {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

