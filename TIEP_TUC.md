# TIẾP TỤC — Phong_ADung (Video Story Publisher V22.99)

> Đọc file này trước khi sửa tool. Cập nhật lại mỗi khi rời tool.

## Trạng thái hiện tại (2026-10-05)
- **Version đang chạy:** v22.99.1
- **Repo GitHub:** https://github.com/NaupUuh/Phong_ADung
- **Thư mục máy:** `Phong_ADung`
- **Cách chạy:** bấm đúp `CHAY_Phong_ADung.bat` (hoặc `viet_drama_V22.99_stable_folder.py`)

## Đã làm xong
- Tách khỏi tool kia: config / crash log / cache riêng, không ghi đè nhau.
- `PROFILE_ID = "V22.99"` ở đầu file — đổi 1 dòng này là tách sang profile khác.
- Đã đưa lên GitHub + cơ chế tự cập nhật (giống News_Clip_Stitcher).
- Nút **⬆ Cập nhật** ở góc trên bên phải cửa sổ: bấm là tự tải bản mới → ghi đè → mở lại.
- `Cai_dat_may_moi.bat` cho máy mới (tải repo về, cài gói thiếu, tạo file chạy).

## Cơ chế tự cập nhật (đã test thật, PASS)
| File | Việc |
|---|---|
| `version.json` | version + notes + date (nguồn so sánh) |
| `updater.py` | tải zip GitHub → giải nén → ghi đè → backup `_backup_update/` |
| `release.py` | phát hành bản mới: `python release.py <ver> "<mô tả>"` |
| `_backup_update/` | backup tự động trước mỗi lần ghi đè (có thể rollback) |

**Khi có bản mới, máy khác chỉ cần:** mở tool → bấm **⬆ Cập nhật**.

### Phát hành bản mới (làm trên máy này)
```
cd Phong_ADung
python release.py 22.100.0 "Mô tả thay đổi"
```
Script tự: kiểm tra version lớn hơn → ghi `version.json` → ghi `APP_VERSION` → commit → push.

## Đường dẫn tài nguyên (đã tách, KHÔNG dùng chung với tool kia)
- Config: `C:\Users\<user>\.video_story_publisher_V22.99.json`
- Crash log: `Phong_ADung\video_story_publisher_crash_V22.99.log`
- Cache: `%LOCALAPPDATA%\VideoStoryPublisher\V22.99\`

## Việc còn lại / gợi ý
- (chưa có yêu cầu mới)

## Lệnh hay dùng
```
# chạy tool
Phong_ADung\CHAY_Phong_ADung.bat

# kiểm tra có bản mới không (không mở GUI)
python updater.py --check

# cập nhật bằng dòng lệnh (không cần mở GUI)
python updater.py --apply

# phát hành bản mới
python release.py 22.100.0 "Mô tả"

# đồng bộ lên ổ Z
python sync_z.py
```

## Lưu ý
- API key (Vilao / ElevenLabs / Gemini) **chỉ nhập trong ô GUI**, KHÔNG đọc từ `.env`, KHÔNG hardcode trong file.
- Config **không** bị cập nhật ghi đè — `updater.py` chỉ ghi đè file thuộc repo.
- Máy mới: chạy `Cai_dat_may_moi.bat` trước, sau đó chỉ cần bấm nút Cập nhật.
