import SwiftUI
import CoreImage.CIFilterBuiltins

struct BarcodePopupView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var qrCodeText: String
    @Binding var message: String
    @Binding var title: String
    
    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    var body: some View {
        
        VStack {
            Text(title).font(.title).foregroundColor(.black)
            Section{
                if let qrCodeImage = generateQRCode(from: qrCodeText) {
                    Image(uiImage: qrCodeImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                } else {
                    Text("Failed to generate QR code \nPlease close & try again.")
                }
            }
            VStack{
                
                HStack{
                    Text(message)
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal).padding(50)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Button("Close") {
                    dismiss()
                }
                .foregroundStyle(.blue)
                .padding()
            }
        }
    }
}
