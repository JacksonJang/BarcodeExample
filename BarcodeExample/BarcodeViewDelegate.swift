protocol BarcodeViewDelegate: AnyObject {
    func complete(status: ReaderStatus)
}
