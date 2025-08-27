//
//  ImageDetailView.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import SwiftUI
import Photos

struct ImageDetailView: View {
    @StateObject private var viewModel: ImageDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(assets: [PHAsset], initialIndex: Int) {
        let vm = ImageDetailViewModel()
        vm.configure(with: assets, initialIndex: initialIndex)
        self._viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                TabView(selection: $viewModel.currentIndex) {
                    ForEach(Array(viewModel.assets.enumerated()), id: \.element.localIdentifier) { index, asset in
                        ImagePageView(asset: asset, viewModel: viewModel)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                Text(viewModel.progressText())
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.bottom, 40)
            }
        }
        .statusBarHidden()
    }
}

struct ImagePageView: View {
    let asset: PHAsset
    let viewModel: ImageDetailViewModel
    
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(scale > 1.0 ? nil : magnificationGesture)
                        .gesture(scale > 1.0 ? magnificationGesture.simultaneously(with: dragGesture(geometry: geometry)) : nil)
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = 2.0
                                }
                            }
                        }
                } else {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Failed to load image")
                            .foregroundColor(.white)
                            .padding(.top, 16)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .task {
            await loadFullImage()
        }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = min(max(scale * delta, 1.0), 4.0)
            }
            .onEnded { _ in
                lastScale = 1.0
                if scale < 1.0 {
                    withAnimation(.spring()) {
                        scale = 1.0
                        offset = .zero
                    }
                }
            }
    }
    
    private func dragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if scale > 1.0 {
                    let maxOffsetX = geometry.size.width / 2
                    let maxOffsetY = geometry.size.height / 2
                    
                    let newOffsetX = lastOffset.width + value.translation.width
                    let newOffsetY = lastOffset.height + value.translation.height
                    
                    let constrainedOffsetX = min(max(newOffsetX, -maxOffsetX), maxOffsetX)
                    let constrainedOffsetY = min(max(newOffsetY, -maxOffsetY), maxOffsetY)
                    
                    offset = CGSize(width: constrainedOffsetX, height: constrainedOffsetY)
                }
            }
            .onEnded { _ in
                lastOffset = offset
                
                if scale <= 1.0 {
                    withAnimation(.spring()) {
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }
    
    private func loadFullImage() async {
        viewModel.loadFullImage(for: asset) { image in
            self.image = image
            self.isLoading = false
        }
    }
}
