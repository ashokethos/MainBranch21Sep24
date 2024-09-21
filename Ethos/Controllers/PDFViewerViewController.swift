//
//  PDFViewerViewController.swift
//  Ethos
//
//  Created by Ashok kumar on 12/09/24.
//

import UIKit
import PDFKit

class PDFViewerViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTopMain: UIView!
    @IBOutlet weak var PdfView: UIView!
    
    var pdfUrl: String?
    var invoiceNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lblTitle.text = "\(invoiceNumber ?? "")"
        DispatchQueue.main.async {
        let pdfViewer = PDFView(frame: self.PdfView.bounds)
            self.PdfView.addSubview(pdfViewer)
        pdfViewer.autoScales = true
        pdfViewer.translatesAutoresizingMaskIntoConstraints = false
        pdfViewer.setValue(true, forKey: "forcesTopAlignment")
            if let url = URL(string: self.pdfUrl ?? ""), let document = PDFDocument(url: url) {
                DispatchQueue.main.async {
                    pdfViewer.document = document
                }
            }
        }
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dowloadPDFBtnAction(_ sender: UIButton) {
        if let filename = extractFilename(from: pdfUrl ?? "") {
            print("Filename without extension: \(filename)")
            savePdf(from: pdfUrl ?? "", fileName: filename)
        } else {
            print("Failed to extract filename.")
        }
    }
    
    func extractFilename(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }
        let filenameWithExtension = url.lastPathComponent
        let filenameWithoutExtension = filenameWithExtension
            .components(separatedBy: ".")
            .first
        
        return filenameWithoutExtension
    }
    
    func savePdf(from urlString: String, fileName: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string.")
            return
        }
        let fileName = url.lastPathComponent
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access documents directory.")
            return
        }
        let destinationFileUrl = documentsUrl.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
            if let alertController = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController {
                alertController.setActions(title: "File already exists.", message: "", secondActionTitle: "Done")
                self.present(alertController, animated: true)
            }
            return
        }
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                    if let alertController = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController {
                        alertController.setActions(title: "File successfully saved!", message: "", secondActionTitle: "Done")
                        DispatchQueue.main.async {
                            self.present(alertController, animated: true)
                        }
                    }
                }
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    let contents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
//                    for indexx in 0..<contents.count {
//                        if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
//                            let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
//                            DispatchQueue.main.async {
//                                self.present(activityViewController, animated: true, completion: nil)
//                            }
//                        }
//                    }
                } catch (let err) {
                    print("Error: \(err)")
                }
            } else {
                print("Error occurred while downloading a file. Error description: \(error?.localizedDescription ?? "")")
            }
        }
        task.resume()
    }
}
