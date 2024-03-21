import UIKit
import AVFoundation

class BarcodeView: UIView{
    weak var delegate: BarcodeViewDelegate?
    
    private let metatdataObjectTypes: [AVMetadataObject.ObjectType] = [.upce, .code39, .code39Mod43, .code93, .code128, .ean8, .ean13, .aztec, .pdf417, .itf14, .dataMatrix, .interleaved2of5, .qr]
    
    private var session: AVCaptureSession = AVCaptureSession()
    private var videoDevice: AVCaptureDevice? = AVCaptureDevice.default(for: .video)
    
    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        return videoPreviewLayer
    }()
    
    private lazy var captureMetadataOutput: AVCaptureMetadataOutput = {
        let captureMetadataOutput = AVCaptureMetadataOutput()
        
        return captureMetadataOutput
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    /**
     비디오 촬영 시작
     */
    public func start() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    /**
     비디오 촬영 중지
     */
    public func stop() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    /**
    카메라 영역 UI 업데이트
     */
    public func updateUI() {
        videoPreviewLayer.frame = self.frame
    }
    
    private func setup() {
        setupUI()
        setupCapture()
    }
    
    private func setupUI() {
        self.layer.addSublayer(videoPreviewLayer)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        
    }
    
    private func setupCapture() {
        guard let videoDevice = videoDevice,
              let captureDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) 
        else {
            return
        }
        
        // 디바이스 사용할 수 있는지 확인 후 추가
        if self.session.canAddInput(captureDeviceInput) {
            self.session.addInput(captureDeviceInput)
        }
        
        // 메타데이터 사용 가능한지 확인 후 추가
        if self.session.canAddOutput(captureMetadataOutput) {
            self.session.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.metadataObjectTypes = metatdataObjectTypes
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        }
    }
}

extension BarcodeView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // 감지 했기 때문에 정지
        stop()
        
        guard let metadata = metadataObjects.first(where: { $0 is AVMetadataMachineReadableCodeObject }) as? AVMetadataMachineReadableCodeObject,
              let code = metadata.stringValue
        else {
            self.delegate?.complete(status: .error)
            return
        }
        
        self.delegate?.complete(status: .success(code: code))
    }
}
