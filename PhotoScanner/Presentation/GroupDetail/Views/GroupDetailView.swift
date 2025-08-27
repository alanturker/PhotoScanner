//
//  GroupDetailView.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import SwiftUI
import Photos

struct GroupDetailView: View {
    @StateObject private var viewModel: GroupDetailViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    init(groupItem: GroupItem) {
        let vm = GroupDetailViewModel()
        vm.configure(with: groupItem)
        self._viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading photos...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        Spacer()
                    }
                    .frame(height: geometry.size.height * 0.6)
                } else if viewModel.assets.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No photos in this group")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(.top, 16)
                        Spacer()
                    }
                    .frame(height: geometry.size.height * 0.6)
                } else {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(Array(viewModel.assets.enumerated()), id: \.element.localIdentifier) { index, asset in
                            PhotoGridItemView(
                                asset: asset,
                                viewModel: viewModel
                            ) {
                                viewModel.selectAsset(at: index)
                            }
                        }
                    }
                    .padding(8)
                }
            }
        }
        .navigationTitle(viewModel.groupItem?.title ?? "Group")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .background(
            NavigationLink(
                destination: ImageDetailView(
                    assets: viewModel.assets,
                    initialIndex: viewModel.selectedIndex
                ),
                isActive: $viewModel.showImageDetail
            ) {
                EmptyView()
            }
                .opacity(0)
        )
        .onAppear {
            if viewModel.assets.isEmpty {
                viewModel.loadAssets()
            }
        }
    }
}

struct PhotoGridItemView: View {
    let asset: PHAsset
    let viewModel: GroupDetailViewModel
    let onTap: () -> Void
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Button(action: onTap) {
            Group {
                if isLoading {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                        }
                } else if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                        }
                }
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .task {
            if image == nil {
                await loadThumbnail()
            }
        }
    }
    
    private func loadThumbnail() async {
        viewModel.loadThumbnail(for: asset, size: CGSize(width: 200, height: 200)) { image in
            self.image = image
            self.isLoading = false
        }
    }
}
