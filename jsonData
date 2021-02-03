extension URL {
    /// Returns '`Data?`' object from a data task called on the URL; along with any errors.
    /// - Parameters:
    ///   - session: The `URLSession` object to handle the data task. Defaults to '`URLSession.shared`'
    ///   - completionHandler: Called upon completion of the data task. Passes '`Data?`' object and '`Error?`' object.
    /// - parameter data: Optional '`Data`' object with MIME type of 'application/json' (JSON data).
    /// - parameter error: Optional '`error`' object passed from data task.
    func getJSONData(_ session: URLSession? = URLSession.shared, completionHandler:@escaping (_ data: Data?, _ error: Error?) -> Void) {
        let task = session?.dataTask(with: self, completionHandler: { (data, response, error) in
            guard let data = data else {
                debugPrint("Data returned was likely 'nil'")
                completionHandler(nil, error)
                return
            }
            
            if error != nil {
                debugPrint("Network error whilst getting JSON data: \(error?.localizedDescription ?? "No Description")")
            }
            
            // Check response type is JSON
            guard let mime = response?.mimeType, mime == "application/json" else {
                debugPrint("Wrong MIME type. Expected 'application/json', was '\(String(describing: response?.mimeType))'")
                return
            }
            
            completionHandler(data, error)
        })
        
        task?.resume()
    }
}
