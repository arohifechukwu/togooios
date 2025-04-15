//
//  PolylineMapView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-15.
//





import SwiftUI
import MapKit

struct PolylineMapView: UIViewRepresentable {
    var region: MKCoordinateRegion
    var markers: [DriverDeliveryView.Marker]
    var route: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)

        // Add Markers
        for marker in markers {
            let annotation = MKPointAnnotation()
            annotation.coordinate = marker.coordinate
            annotation.title = marker.label
            uiView.addAnnotation(annotation)
        }

        // Add Polyline with Arrow
        if route.count > 1 {
            let polyline = DirectionalPolyline(coordinates: route, count: route.count)
            uiView.addOverlay(polyline)
        }

        uiView.setRegion(region, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }

            let identifier = "Marker"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            // Tint color by label
            if let title = annotation.title ?? "" {
                if title.contains("Driver") {
                    annotationView?.markerTintColor = .systemBlue
                } else if title.contains("Restaurant") {
                    annotationView?.markerTintColor = .systemRed
                } else if title.contains("Customer") {
                    annotationView?.markerTintColor = .systemGreen
                } else {
                    annotationView?.markerTintColor = .gray
                }
            }

            return annotationView
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? DirectionalPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemTeal
                renderer.lineWidth = 4
                renderer.lineDashPattern = [6, 4]
                renderer.lineCap = .round
                return renderer
            }

            return MKOverlayRenderer()
        }
    }
}

// MARK: - DirectionalPolyline (Subclass for future extension)
class DirectionalPolyline: MKPolyline {}



