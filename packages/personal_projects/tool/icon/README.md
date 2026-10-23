# Công cụ sinh icon

Sinh toàn bộ icon iOS và Android từ một file nguồn duy nhất:
`design/app_icon_chichi_projects.png`.

Công cụ nằm ngoài cây phụ thuộc của app — nó là script Dart độc lập, chạy bằng
SDK đã ghim của FVM. Cố ý **không** thêm `flutter_launcher_icons` vào
`dev_dependencies`: mọi gói mới đều phải qua vòng kiểm tra build hooks của
AD-13, mà việc này thì chạy một lần rồi thôi.

## Chạy

```bash
cd tool/icon
~/fvm/versions/3.38.10/bin/dart pub get

~/fvm/versions/3.38.10/bin/dart run icontool.dart \
  ../../design/app_icon_chichi_projects.png \
  ../../ios/Runner/Assets.xcassets/AppIcon.appiconset \
  ../../android/app/src/main/res \
  ../../design/app_icon_1024.png
```

Thêm `preview-only` vào cuối để chỉ xuất bản 1024 mà chưa ghi đè bộ icon thật.

`probe.dart` dùng để đo lại toạ độ khi thay ảnh nguồn khác:

```bash
~/fvm/versions/3.38.10/bin/dart run probe.dart ../../design/app_icon_chichi_projects.png
```

## Vì sao phải ghép chứ không cắt thẳng

Ảnh nguồn là **ảnh giới thiệu**, không phải file icon: ô icon bo góc 638×555 nằm
trên nền navy nhạt hơn chính nó, kèm dòng chữ "Chichi PROJECTS" phía dưới.

Cắt thẳng ô icon ra thì gặp ba vấn đề: nó không vuông; cắt vuông thì mất lề hai
bên và glyph chạm mép; bốn góc bo cùng mép trên dưới lộ vệt nền ngoài sáng hơn.

Nên công cụ ghép lại: dựng khung vuông bằng đúng màu nền trong ô (`#030b1e`, là
màu phẳng), cắt riêng vùng glyph kèm quầng sáng rồi dán vào giữa. Nền của vùng
glyph trùng màu khung nên không để lại đường nối.

Glyph được căn vào **đúng tâm**. Trong ảnh gốc nó lệch trái 33 điểm so với tâm ô
icon — trên một icon vuông thì lệch tâm trông như lỗi.

## Ràng buộc

- Icon **tràn viền, không bo góc sẵn**: iOS và Android tự bo theo cách riêng.
- Icon iOS **không được có kênh trong suốt**. Công cụ dựng ảnh 3 kênh, kiểm lại
  bằng `sips -g hasAlpha <file>`.
- Đổi tỷ lệ glyph thì sửa hằng `fillRatio` trong `icontool.dart` (đang là 0,62).
