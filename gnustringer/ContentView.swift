//
//  ContentView.swift
//  gnustringer
//
//  Created by Benedikt Gottstein on 20.05.2025.
//

import SwiftUI
import SwiftData
import LaunchAtLogin
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecentFile.lastUsed, order: .reverse)
    private var recentFiles: [RecentFile]
    @Query(sort: \RecentDirectory.lastUsed, order: .reverse)
    private var recentDirs: [RecentDirectory]
    
    @State private var directories: String = ""
    @State private var fileName: String = ""
    
    @State private var xCol = ""
    @State private var xScale = ""
    
    @State private var yCol = ""
    @State private var yScale = ""
    
    @State private var cbCol = ""
    
    @State private var styleIndex = 1
    private let styles = ["nothing", "w l", "w lp"]
    
    @State private var longString: Bool = true
    
    @State private var result = ""
    @State private var textHeight: CGFloat = 40
    
    @State private var showResultInTextfield: Bool = false
    @State private var autoCopyOnGenerate: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image("rainbow")
//                .resizable()
//                .frame(height: 50)
                .padding(.vertical,-10)
            Group {
                HStack {
                    TextField("Directories (space-separated)", text: $directories)
                        .frame(minWidth: 280)
                    
                    Menu {
                        ForEach(recentDirs) { dir in
                            Button(dir.path) {
                                if !directories.contains(dir.path) {
                                    directories = dir.path
                                }
                                updateRecentDirectory(path: dir.path)
                            }
                        }
                        Button {
                            deleteDirectoryItems()
                        } label: {
                            Text("🗑️ delete history 🗑️")
                                .font(.system(.body, design: .monospaced))
                        }

                    } label: {
                        Text("...")
                            .font(.system(.body, design: .monospaced))
                            .help("Choose from common files")
                    }
                }
                
                HStack {
                    TextField("File Name", text: $fileName)
                        .frame(minWidth: 280)
                    
                    Menu {
                        ForEach(recentFiles) { file in
                            Button(file.name) {
                                fileName = file.name
                                updateRecentFile(named: file.name)
                            }
                        }
                        Button {
                            deleteFilesItems()
                        } label: {
                            Text("🗑️ delete history 🗑️")
                                .font(.system(.body, design: .monospaced))

                        }

                    } label: {
                        Text("...")
                            .font(.system(.body, design: .monospaced))
                            .help("Choose from common files")
                    }
                }
            }
            
            HStack {
                TextField("X Col", text: $xCol)
                TextField("X Scale", text: $xScale)
            }
            
            HStack {
                TextField("Y Col", text: $yCol)
                TextField("Y Scale", text: $yScale)
            }
            
            TextField("CB Col (optional)", text: $cbCol)
            
            Picker("Plot Style", selection: $styleIndex) {
                ForEach(0..<styles.count, id: \.self) { index in
                    Text(styles[index])
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 10)
            
            HStack() {
                Spacer()
                Button("Generate") {
                    if (!fileName.isEmpty)    { updateRecentFile(named: fileName) }
                    if (!directories.isEmpty) { updateRecentDirectory(path: directories) }
                    showResultInTextfield = false
                    result = generateGnuplotCommand()
                    if result != "Invalid numeric input." {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(result, forType: .string)
                    }
                }
                
                Button("Copy") {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(result, forType: .string)
                }
                
                Toggle("line breaks", isOn: $longString)
                    .font(.system(.caption, design: .monospaced))
                    .toggleStyle(.checkbox)
                
                Spacer()
            }
            
            if showResultInTextfield {
                
                VStack(alignment: .leading) {
                    TextEditor(text: $result)
                        .font(.system(size: 11, design: .monospaced))
                        .frame(height: max(textHeight+100, 40)) // default min height
                        .padding(4)
                        .background(Color(NSColor.windowBackgroundColor))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.5)))
                    
                    // Hidden text to measure height
                    Text(result.isEmpty ? " " : result)
                        .font(.system(size: 11, design: .monospaced))
                        .padding(6)
                        .frame(width: 300, alignment: .leading)
                        .background(GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    textHeight = geo.size.height
                                }
                                .onChange(of: result) {
                                    textHeight = geo.size.height
                                }
                        })
                        .hidden()
                }
                .frame(maxWidth: .infinity)
                
            } else {
//                ScrollView(.vertical) {
                Text(result)
                    .font(.system(size: 11, design: .monospaced))
                    .padding(.top, 4)
                    .onTapGesture(count: 2) {
                        showResultInTextfield.toggle()
                    }
                //                }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 7)
                    .background(result.isEmpty ? Color.clear : Color(NSColor.windowBackgroundColor))
                    .cornerRadius(10)
                    .clipped()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(result.isEmpty ? 0.0 : 0.3)))
            }
            
            Divider()
            
            HStack {
                Text("🪐 made by Beni")
                    .font(.system(.caption, design: .monospaced))
//                Text("(v" + currentVersion + ")")
//                    .font(.caption2)
//                    .fontWeight(.ultraLight)
//
                Spacer()
                
                Toggle("auto copy", isOn: $autoCopyOnGenerate)
                    .toggleStyle(.checkbox)
                    .font(.caption)
                Spacer()
                
                LaunchAtLogin.Toggle()
                    .font(.system(.caption, design: .monospaced))


                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .keyboardShortcut("q")
            }
            .padding(.bottom, -8)

        }
        .font(.system(.body, design: .monospaced))
        .padding()
        .frame(width: 380)
    }
    
    func generateGnuplotCommand() -> String {
        let dirs = directories.split(separator: " ").map(String.init)
        
        // Fallback to 1.0 if empty or invalid
        let xS = Double(xScale.trimmingCharacters(in: .whitespaces)).flatMap { $0 != 0 ? $0 : nil } ?? 1.0
        let yS = Double(yScale.trimmingCharacters(in: .whitespaces)).flatMap { $0 != 0 ? $0 : nil } ?? 1.0
        
        guard let x = Int(xCol), let y = Int(yCol) else {
            return "Invalid numeric input."
        }
        
        let hasCB = !cbCol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let baseArgs = styles[styleIndex]
        let args = baseArgs + (hasCB && baseArgs != "nothing" ? " pal" : "")
        
        let parts = dirs.map { dir in
            let file = "\(dir)/\(fileName)"
            
            let xString = (xS == 1) ? "\(x)" : "($\(x)/\(xS))"
            let yString = (yS == 1) ? "\(y)" : "($\(y)/\(yS))"
            let cbString = hasCB ? ":\(cbCol)" : ""
            
            let withClause = baseArgs == "nothing" ? "" : args
            return "\"\(file)\" u \(xString):\(yString)\(cbString) \(withClause)".trimmingCharacters(in: .whitespaces)
        }
        
        print("GENERATED:")
        print("plot " + parts.joined(separator: !longString ? ", " : ", \\\n     "))
        return "plot " + parts.joined(separator: !longString ? ", " : ", \\\n     ")
    }
    
    private func updateRecentFile(named name: String) {
        if let existing = recentFiles.first(where: { $0.name == name }) {
            existing.lastUsed = .now
        } else {
            let new = RecentFile(name: name)
            modelContext.insert(new)
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to update recent file: \(error)")
        }
    }
    
    private func updateRecentDirectory(path: String) {
        if let existing = recentDirs.first(where: { $0.path == path }) {
            existing.lastUsed = .now
        } else {
            let new = RecentDirectory(path: path)
            modelContext.insert(new)
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to update recent directory: \(error)")
        }
    }
    
    func deleteDirectoryItems() {
        let fetchDescriptor = FetchDescriptor<RecentDirectory>()
        do {
            let allItems = try modelContext.fetch(fetchDescriptor)
            for item in allItems {
                modelContext.delete(item)
            }
            try modelContext.save()
        } catch {
            print("Failed to clear history: \(error)")
        }
    }
    
    func deleteFilesItems() {
        let fetchDescriptor = FetchDescriptor<RecentFile>()
        do {
            let allItems = try modelContext.fetch(fetchDescriptor)
            for item in allItems {
                modelContext.delete(item)
            }
            try modelContext.save()
        } catch {
            print("Failed to clear history: \(error)")
        }
    }

    
}

#Preview {
    ContentView()
        .modelContainer(for: RecentFile.self, inMemory: true)
}
