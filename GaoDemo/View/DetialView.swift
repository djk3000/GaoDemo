//
//  DetailView.swift
//  GaoDemo
//
//  Created by 邓璟琨 on 2023/3/2.
//

import SwiftUI

struct DetialView: View {
    @ObservedObject var vm: GaoViewModel
    @Binding var showDilog: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(vm.selectedNamePoi?.name ?? "")
                    .bold()
                    .font(.system(size: 14))
                
                Text(vm.selectedNamePoi?.address ?? "地址")
                    .font(.caption)
                
                HStack(spacing: 0) {
                    Text("电话: ")
                    Text(vm.selectedNamePoi?.tel ?? "")
                }
                .font(.caption)
                
                HStack (spacing: 0){
                    Text("评分: ")
                    Text(vm.selectedNamePoi?.rating?.description ?? "0.0")
                    Text(" 非常棒")
                }
                .foregroundColor(.blue)
                .font(.caption)
                
                Text(vm.selectedNamePoi?.type ?? "")
                    .font(.caption)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(vm.selectedNamePoi?.image ?? [], id: \.self) { item in
                            AsyncImage(url: URL(string: item)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 150, height: 100)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.top)
                
                HStack {
                    Button(action: {
                        self.showDilog = false
                    }) {
                        Text("全部")
                            .padding()
                            .frame(width: 150, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Text("导航")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 40)
                    }
                    .background(Color.blue)
                    .cornerRadius(40)
                }
                .padding(.top)
            }
            .padding()
            Spacer()
        }
        .padding(.leading)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetialView(vm: GaoViewModel(), showDilog: .constant(true))
            .previewLayout(.sizeThatFits)
    }
}
