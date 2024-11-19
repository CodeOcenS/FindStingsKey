// 编译文件。swiftc -o FindStringsKey xxx.swift
// 运行  ./FindStringsKey 路径

import SwiftUI
import Vision
import Foundation

func handleDetectedText(request: VNRequest?, error: Error?) {
    if let error = error {
        print("ERROR: \(error)")
        return
    }
    guard let results = request?.results, results.count > 0 else {
        print("No text found")
        return
    }

    //通过循环将results的结果全部打印
    //你可以在这里进行一些处理，比如说创建一个数据结构来获取获取文本区域的位置和大小，或者一些其他的功能。！！！通过observation的属性就可以获取这些信息！！！
    for result in results {
        if let observation = result as? VNRecognizedTextObservation {
            //topCandidates(1)表示在候选结果里选择第一个，最多有十个，你也可以在这里进行一些处理
            for text in observation.topCandidates(1) {
                //打印识别的文本字符串
                let string = text.string
                //print(string)
                printMatchKey(string: string)
            }
        }
    }
}
var strings:[String: String] = [:]
func printMatchKey(string: String) {
    if strings.count == 0 {
        // todo: 添加多语言 stings 文件路径（示例：file://xxxxx/en.lproj/Localizable.strings），用于匹配 key
        let keyStringPath = "file://xxxxx/en.lproj/Localizable.strings"
        guard let url = URL(string: keyStringPath) else {
            print("路径异常")
            return
        }
        guard let dict = try? NSMutableDictionary.init(contentsOf: url, error: ()) else {
            print("获取 strings 失败")
            return
        }
        strings = dict as! [String : String]
    }
    var matchKeys: [String] = []
    strings.forEach { (key: String, value: String) in
        if !string.contains(" "){
            // 不含空格，必须全匹配
            if value == string  {
                matchKeys.append(key)
            }
        } else {
            if value.contains(string) {
                matchKeys.append(key)
            }
        }
    }
    if matchKeys.count > 0 {
        let keys = matchKeys.joined(separator: "，")
        print("【\(keys)】\(string)")
    } else {
        print(string)
    }
}

func ocrImage(path: String) {
    let cgImage = NSImage(byReferencingFile: path)?.ciImage()?.cgImage

    //创建一个新的图像请求处理器
    let requestHandler = VNImageRequestHandler(cgImage: cgImage!)
    //创建一个新的识别文本请求
    let request = VNRecognizeTextRequest(completionHandler: handleDetectedText)
    //使用accurate模式识别，不推荐使用fast模式，因为这是采用传统OCR的，精度太差了
    request.recognitionLevel = .accurate
    //设置偏向语言，不加的话会全按照英文和数字识别。
    //跟中文一起能识别的其他文字只有英文
    //繁体中文为zh-Hant，其他语言码请见https://www.loc.gov/standards/iso639-2/php/English_list.php
    request.recognitionLanguages = ["zh-Hans"]

    do {
        //执行文本识别的请求
        try requestHandler.perform([request])
    } catch {
        print("Unable to perform the requests: \(error).")
    }
}

extension NSImage {
    //NSImage转CIImage
    func ciImage() -> CIImage? {
        guard let data = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data) else {
            return nil
        }
        let ci = CIImage(bitmapImageRep: bitmap)
        return ci
    }
}

//ocrImage(path: "/Users/zhongyijiang/Desktop/card.png")
//for _ in 0...100 {
    ocrImage(path: CommandLine.arguments[1])
//}

