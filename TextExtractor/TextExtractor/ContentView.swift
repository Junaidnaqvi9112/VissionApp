//
//  ContentView.swift
//  TextExtractor
//
//  Created by Syed Junaid Abbas on 15/01/2024.
//

import SwiftUI
import UIKit
import Vision

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var extractedText: String = ""

    var body: some View {
        VStack(spacing: 30) {
            ImagePicker(image: $selectedImage)
                .frame(maxWidth: .infinity, maxHeight: 300)
                .padding(.horizontal)

            Text(extractedText)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .padding(.horizontal)

            Button("Extract Text", action: extractText)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }

    func extractText() {
        guard let selectedImage = selectedImage else {
            return
        }

        if let ciImage = CIImage(image: selectedImage) {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            let request = VNRecognizeTextRequest { request, error in
                if let results = request.results as? [VNRecognizedTextObservation] {
                    self.extractedText = results.map { $0.topCandidates(1).first?.string ?? "" }.joined(separator: " ")
                }
            }

            do {
                try handler.perform([request])
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
#Preview {
    ContentView()
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            picker.dismiss(animated: true, completion: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
}
