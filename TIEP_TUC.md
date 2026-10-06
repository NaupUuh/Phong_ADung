# TIẾP TỤC — Phong_ADung

**Phiên bản hiện tại: v22.100.8** (06/10/2026)

## Trạng thái: ĐANG CHẠY ỔN

## Việc vừa xong (v22.100.8) — TỐI ƯU TỈ LỆ ĐĂNG ĐƯỢC BÀI

Bối cảnh: hôm 06/10 có khung giờ **73–88% bài bị 502** (12:20–17:15), 97 bài lỗi.
Nguyên nhân đã chốt: **Cloudflare `origin_bad_gateway`** trên zone `dramanest.gigglelo.com`
— origin quá tải **tức thời**, KHÔNG phải payload/tool/rate. Bằng chứng: 12/12 payload từng
502 replay lại → **201 OK 1.2–1.6s**; 10 POST nặng đồng thời → 201 cả 10; 107 bài 201 cùng ngày.

**Vấn đề thật sự làm "mất thời gian":** retry 3 lần × backoff 60/120s ≈ **4 phút/bài lỗi**.
100 bài lỗi = ~6 giờ chờ, mà origin sập hàng giờ thì chờ vài phút không cứu được bài nào.

### 1. Lưu payload khi lỗi → tự đăng lại sau (MỚI)
- Gặp `502/503/504/429/520–524` hoặc lỗi mạng → ghi `publish_pending_adsconex.json` vào
  `work_dir` (chứa payload + http_status + detail + saved_at + machine).
- **KHÔNG tốn Vision/Writer** — chỉ gửi lại đúng payload đã lưu.
- Đăng lại thành công → tự xoá dấu pending + tự ghi `publish_result.json` + `chapter_links.txt`
  + **tự đổi tên video** (đọc lại `story.json` + `source_video.json`).
- **An toàn, không sinh bài trùng:** 12/12 bài 502 trước đó đều trả `404` → 502 nghĩa là
  **chưa hề tạo bài**.

### 2. Tự đăng lại ở cuối batch (MỚI)
- Sau khi batch chạy xong, tool quét `Story Outputs`, đăng lại mọi bài còn pending.
- Cập nhật lại `rows` (bài lỗi → thành công) nên `batch_result_*.json` + `net_titles_*.txt`
  phản ánh đúng.
- **Dừng sớm:** 3 bài liên tiếp vẫn lỗi → dừng (origin chưa hồi), giữ nguyên payload cho lần sau.
- Bỏ qua folder **đã đăng thành công** (`publish_result.json` có url/id).

### 3. Nút "Đăng lại bài lỗi" trong tab Adsconex (MỚI)
- Chọn folder batch ở ô đường dẫn → bấm nút → xác nhận → chạy nền.
- Kiểm tra trước: net phải là Adsconex + phải có token; báo rõ số bài tìm thấy.
- Xong hiện hộp thoại: thành công bao nhiêu, còn lỗi bao nhiêu (bấm lại sau vài phút).

### 4. Circuit breaker — cắt cơn chờ vô ích (MỚI)
- **2 bài lỗi tạm thời LIÊN TIẾP** → các bài sau **chỉ thử 1 lần** rồi lưu payload luôn.
- Biến đếm là **trạng thái chung cả tiến trình** (`_adsconex_fail_streak` + Lock), KHÔNG phải
  thuộc tính instance — vì batch tạo `StoryPipeline` mới cho mỗi video, dùng instance sẽ bị reset.
- Thành công → streak về 0. Chỉ `502/503/504/429/520–524` + lỗi mạng mới tính là lỗi;
  **422/401/500 KHÔNG** kích breaker.

### 5. Retry 502 (từ v22.100.6, vẫn giữ)
- Retry `502/503/504/429/520–524` + lỗi mạng, backoff theo `Retry-After` (mặc định 60s,
  tối đa 3 lượt, trần 300s). `500`/`401` **KHÔNG** retry.

### 6. Các bản vá cũ vẫn giữ
- **Rate-limit 6 bài/phút tổng** cho mọi máy (mutex `O_CREAT|O_EXCL` trên Z) — v22.100.7.
- **Vá 422 `seo_description`** (chuỗi chứa `--`): làm sạch + gỡ trường rồi đăng lại — v22.100.7.

## Test đã chạy (PASS)

- **Đăng lại thật 1 bài** lên site: **HTTP 201, 10 chapters, 4.7s**; `GET /posts/<slug>` → **200**
  (bài tồn tại thật). Không tốn Vision/Writer.
- **4/4 bài đăng lại thành công** (mô phỏng batch).
- **Circuit breaker:** bài 1–2 = 16.6s (3 call) → **bài 3+ = 1.6s (1 call)**; streak reset đúng
  khi thành công; 422 không kích breaker.
- **7/7 test** (pending roundtrip, bỏ qua folder đã đăng, lỗi mạng lưu payload, 422 gỡ trường).
- `py_compile` OK; CRLF giữ nguyên (**6854 CRLF / 0 LF-only**).

## Lệnh hay dùng

```bash
PY="C:/Users/Admin/AppData/Local/Programs/Python/Python313/python.exe"
cd /c/Users/Admin/Desktop/Phong_ADung

# Phát hành bản mới (tự commit + push)
"$PY" release.py 22.100.X "mo ta"

# Sync ổ Z (đối chiếu MD5)
"$PY" sync_z.py

# Kiểm tra cú pháp sau khi sửa
"$PY" -m py_compile viet_drama_V22.99_stable_folder.py
```

## Việc còn lại / lưu ý

- **108 bài còn payload trong folder batch hôm 06/10** chưa đăng lại — dùng nút
  **"Đăng lại bài lỗi"** (hoặc chạy lại batch) khi origin đã hồi.
- **Mỗi máy phải dùng 1 folder riêng** — 2 máy cùng đăng 1 folder sẽ đăng trùng.
- Nếu Z không kết nối được, tool **chỉ giãn cách tại máy** (15s) → nhiều máy có thể vượt trần chung
  (hành vi có chủ đích, không chặn việc).
- Backup bản cũ nằm trong `_backup_old/` (đuôi `.bak`).
- **File này dùng CRLF** (không phải LF).

## Bản vá đã dùng (trong `%LOCALAPPDATA%\Temp\ads502\patch_scripts\ADung\`)

`_patch502.py` (khung 502 recovery) → `_patch502b.py` → `_patch502c.py` (breaker thành biến
module) → `_patch502d.py` (ngưỡng 2 + dừng sớm cuối batch).
