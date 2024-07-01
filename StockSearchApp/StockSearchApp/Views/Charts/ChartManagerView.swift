//
//  ChartManagerView.swift
//  StockSearchApp
//
//  Created by Siddarth Mohan on 4/8/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var data : String

    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil

    func makeCoordinator() -> WebView.Coordinator {
        var abc = Coordinator(self)
        abc.setData(dataa: data)
        return abc
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.load(URLRequest(url: Bundle.main.url(forResource: "hw4Charts", withExtension: "html")!))
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {

    }

    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var data : String = ""
        func setData(dataa : String){
            data = dataa
        }
        let parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript(data, completionHandler: {result,err in print(err)})
            parent.loadStatusChanged?(false, nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
    }
}



struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(data : "hourlyChart(fakeHourlyData, 'AAPL', 'green')")
    }
}
