import UIKit
import Vision


class MainViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textFieldView: UITextView!
    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!
    
    var request = VNRecognizeTextRequest(completionHandler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopAnimation()
        
        
    }
   private func startAnimation() {
    self.activeIndicator.startAnimating()
    }
    private func stopAnimation() {
        self.activeIndicator.stopAnimating()
    }
    

    @IBAction func cameraButton(_ sender: Any) {
        setupGallery()
        
    }
    
    private func setupGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let imagePhotoLibraryPicker = UIImagePickerController()
            imagePhotoLibraryPicker.delegate = self
            imagePhotoLibraryPicker.allowsEditing = true
            imagePhotoLibraryPicker.sourceType = .photoLibrary
            self.present(imagePhotoLibraryPicker, animated: true, completion: nil)
        }
    }
    
    private func setupVisionTextRecognizeImage(image: UIImage?) {
        
        var textString = ""
        request = VNRecognizeTextRequest(completionHandler: { (request, error) in
            
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {fatalError("Recieved Invalid observation")}
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    print("No candidate")
                    continue
                }
                
                textString += "\n\(topCandidate.string)"
                
                DispatchQueue.main.async {
                    self.stopAnimation()
                    self.textFieldView.text = textString
                }
            }
        })
        
        request.customWords = ["custOm"]
        request.minimumTextHeight = 0.03125
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"] /// add russian
        request.usesLanguageCorrection = true
        
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let img = image?.cgImage else {fatalError("Missing image")}
            let handle = VNImageRequestHandler(cgImage: img, options: [:])
            try? handle.perform(requests)
        }
        
        
    }
}


extension MainViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        startAnimation()
        self.textFieldView.text = ""
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        self.imageView.image = image
        setupVisionTextRecognizeImage(image: image)
    }
    
}
