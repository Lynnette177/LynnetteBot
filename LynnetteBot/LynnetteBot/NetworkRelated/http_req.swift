import Foundation

// 定义一个函数，封装POST请求
func postRequest(url: String, body: [String: Any], timeout: TimeInterval = 10, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    // 确保URL有效
    guard let url = URL(string: url) else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    // 创建URLRequest
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        // 将字典转换为JSON数据
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
    } catch {
        completion(.failure(error))
        return
    }
    
    // 创建一个URLSessionConfiguration并设置超时
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = timeout // 设置请求超时
    configuration.timeoutIntervalForResource = timeout // 设置资源加载超时
    
    // 使用配置创建URLSession
    let session = URLSession(configuration: configuration)
    
    // 创建URLSession任务
    let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        
        do {
            // 尝试将返回数据解析为JSON
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                completion(.success(jsonResponse))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // 启动任务
    task.resume()
}

import Foundation

// 定义一个函数，封装POST请求，支持同时上传JSON和文件
func postRequestWithJSONAndFile(url: String, jsonBody: [String: Any], fileData: Data, fileName: String, timeout: TimeInterval = 10, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    // 确保URL有效
    guard let url = URL(string: url) else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }

    // 创建URLRequest
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // 设置Content-Type为multipart/form-data
    let boundary = "Boundary-\(UUID().uuidString)"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    // 创建multipart/form-data的请求体
    var body = Data()
    
    // 添加JSON数据部分
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"json\"\r\n\r\n")
        body.append(jsonData)
        body.append("\r\n")
    } catch {
        completion(.failure(error))
        return
    }
    
    // 添加文件数据部分
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
    body.append("Content-Type: application/octet-stream\r\n\r\n")
    body.append(fileData)
    body.append("\r\n")

    // 结束boundary
    body.append("--\(boundary)--\r\n")

    // 设置HTTPBody
    request.httpBody = body

    // 创建一个URLSessionConfiguration并设置超时
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = timeout
    configuration.timeoutIntervalForResource = timeout
    
    // 使用配置创建URLSession
    let session = URLSession(configuration: configuration)
    
    // 创建URLSession任务
    let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        
        do {
            // 尝试将返回数据解析为JSON
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                completion(.success(jsonResponse))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // 启动任务
    task.resume()
}

// 扩展Data以便更方便地追加内容
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

