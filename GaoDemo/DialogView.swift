//
//  DialogView.swift
//  GaoDemo
//
//  Created by 邓璟琨 on 2023/2/27.
//

import SwiftUI

struct DialogView: View {
    @ObservedObject var vm: GaoViewModel
    @Binding var showDilog: Bool
    
    var body: some View {
        ZStack {
            Color.white
            
            //            VStack {
            //                HStack {
            //                    Spacer()
            //
            //                    Image(systemName: "xmark.circle")
            //                        .resizable()
            //                        .frame(width: 20, height: 20)
            //                        .foregroundColor(.blue)
            //                }
            //                Spacer()
            //            }
            //            .padding()
            
            VStack {
                HStack(alignment: .center) {
                    AsyncImage(url: URL(string: vm.selectedNamePoi?.image?.first ?? "")) { image in
                        image
                            .resizable()
                        
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 100, height: 100)
                    .padding(.leading)
                    
                    VStack (alignment: .leading,spacing: 5) {
                        Text(vm.selectedNamePoi?.name ?? "希尔顿")
                            .font(.headline)
                        Text(vm.selectedNamePoi?.address ?? "希尔顿")
                            .font(.caption)
                        
                        HStack(spacing: 0) {
                            Text("电话: ")
                            Text(vm.selectedNamePoi?.tel ?? "")
                        }
                        
                        HStack (spacing: 0){
                            Text("评分: ")
                            Text(vm.selectedNamePoi?.rating?.description ?? "5.0")
                            Text(" 非常棒")
                        }
                        .foregroundColor(.blue)
                        
                        Text(vm.selectedNamePoi?.type ?? "酒店")
                    }
                    .font(.caption)
                    .padding()
                    
                    Spacer()
                }
            }
        }
        .frame(height: 150)
        .cornerRadius(20)
        .padding()
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView(vm: GaoViewModel(), showDilog: .constant(false))
            .previewLayout(.sizeThatFits)
    }
}
