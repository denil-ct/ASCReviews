//
//  CSVDocument.swift
//  ASCReviews
//
//  Created by Denil C T on 6/11/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVDocument: FileDocument {
    var text: String = ""
    static public var readableContentTypes: [UTType] = [.commaSeparatedText]
    
    init(_ text: String = "") {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration)
    throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
