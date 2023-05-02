//
//  ContentView.swift
//  CatsOrDogs
//
//  Created by Tanmay Nema on 02/05/23.
//

import SwiftUI
import CoreML

extension UIImage {
    
    // https://www.hackingwithswift.com/whats-new-in-ios-11
    func toCVPixelBuffer() -> CVPixelBuffer? {
           
           let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
             var pixelBuffer : CVPixelBuffer?
             let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
             guard (status == kCVReturnSuccess) else {
               return nil
             }

             CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
             let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

             let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
             let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

             context?.translateBy(x: 0, y: self.size.height)
             context?.scaleBy(x: 1.0, y: -1.0)

             UIGraphicsPushContext(context!)
             self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
             UIGraphicsPopContext()
             CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

             return pixelBuffer
       }
}

struct ContentView: View {
    
    let images = ["cat989", "cat990 ", "cat991", "dog977", "dog978", "dog979"]
    var ImageClassifier: CatDogImageClassifier?
    @State private var CIndex = 0
    @State private var classLabel: String = ""
    
    init() {
        do {
            ImageClassifier = try CatDogImageClassifier(configuration: MLModelConfiguration())
        } catch {
            print(error)
        }
    }
    
    var isPreviousButtonValid: Bool {
           CIndex != 0
       }
       
       var isNextButtonValid: Bool {
           CIndex < images.count - 1
       }
    
    var body: some View {
        VStack {
            Image(images[CIndex])
            
            Button("Predict") {
                            
                            // uiImage
                            guard let uiImage = UIImage(named: images[CIndex]) else { return }
                            
                            // pixel buffer
                            guard let pixelBuffer = uiImage.toCVPixelBuffer() else { return }
                            
                            do {
                                let result = try ImageClassifier?.prediction(image: pixelBuffer)
                                 classLabel = result?.classLabel ?? ""
                            } catch {
                                print(error)
                            }
                            
                        }.buttonStyle(.borderedProminent)
            
            Text(classLabel)
            
            HStack {
                            
                            Button("Previous") {
                                CIndex -= 1
                            }.disabled(!isPreviousButtonValid)
                            
                            Button("Next") {
                                CIndex += 1
                            }
                            .disabled(!isNextButtonValid)
                            .padding()
                        }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
