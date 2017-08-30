import Vapor

/// View Renderer to use for testing. Captures passed-in arguments.
class CapturingViewRenderer: ViewRenderer {
    var capturedData: ViewData?
    var capturedPath: String?

    var shouldCache = false

    func make(_ path: String, _ data: ViewData) throws -> View {
        self.capturedData = data
        self.capturedPath = path
        return View(data: [])
    }
}

// MARK: Droplet extension

extension Droplet {
    var capturingViewRenderer: CapturingViewRenderer {
        return view as! CapturingViewRenderer
    }

    var capturedViewData: ViewData? {
        return capturingViewRenderer.capturedData
    }

    var capturedViewPath: String? {
        return capturingViewRenderer.capturedPath
    }
}
