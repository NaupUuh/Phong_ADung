# TIẾP TỤC — Phong_ADung (v22.100.14)

Cập nhật: 2026-10-12

## TRẠNG THÁI: CHẠY ỔN
- File chính: `viet_drama_V22.99_stable_folder.py` (**LF-only**, py_compile OK, 7178 dòng).
- Bản đang chạy: **v22.100.14**. GitHub + ổ Z đã đồng bộ (13/13 MD5 khớp).
- Config thật: `C:\Users\Admin\.video_story_publisher_V22.99.json` (71 key, KHÔNG có placeholder).
- **KHÔNG được ghi đè config này.** Test GUI phải kiểm MD5 trước/sau.

## LỊCH SỬ BẢN GẦN ĐÂY
| Bản | Nội dung |
|---|---|
| v22.100.12 | Chia nhỏ request >36KB (502), nút đăng lại nhặt 502, chống trùng qua /series, fix `https://https://`, fix NameError `e` |
| v22.100.13 | **Fix TREO khi đăng bài do LỆCH ĐỒNG HỒ** (3 lớp: giờ máy, bỏ mark tương lai, chờ tối đa 25s) |
| v22.100.14 | **Không lưu thư mục frames** — tự xoá ảnh trung gian sau khi xong; có ô tick "Giữ lại thư mục frames" |

## NGUYÊN NHÂN GỐC 502 `origin_bad_gateway` (đã chốt — QUAN TRỌNG)
502 khi đăng Adsconex **KHÔNG phải do token, KHÔNG do payload bẩn**.
Origin site (dramanest.gigglelo.com) **timeout ~10–11 giây** khi request quá lớn:
- POST /posts content **> ~50KB** → Cloudflare 502 sau ~11s.
- Cùng content đó **<= ~40KB** → 201 trong 2–9s.
- Tất định. Bisect: 1..7 chương (40KB) OK; 1..8 (47KB) 502.
⇒ Ngưỡng theo **TỔNG dung lượng content**, không theo chương cụ thể. An toàn: ~36KB/request.

## ĐÃ VÁ (tóm tắt, chi tiết trong git log)
1. **Chia nhỏ request** (`adsconex_split_chunks` + `_adsconex_send_all`) — vá chính cho 502.
   - Cắt tại ranh giới `<p>CHAPTER N - ...</p>`; phần 2 trở đi **BẮT BUỘC** kèm `series_id`.
   - Không có series_id thì **mỗi POST tạo 1 series mới → chương bị tách** (đã bị thật).
   - Nghỉ giữa các phần: `adsconex_chunk_gap_seconds` (mặc định 3s).
2. **Nút "Đăng lại bài lỗi"** nhặt cả `401/403/429/500/502/503/504/520-524/network`.
3. **Chống đăng trùng** — `adsconex_existing_slugs()` đối chiếu với `/series`, bỏ qua bài đã có.
4. **Nút "Lấy link site"** ra `https://https://...` khi config đã có scheme → đã sửa.
5. **`NameError: free variable 'e'`** trong `self.after(0, lambda: ...)` → gán `_err = str(e)` trước.
6. **TREO do lệch đồng hồ** — xem mục dưới.
7. **Không lưu frames** — `cleanup_frames()` gọi ở 3 chỗ (cuối `run`, khi lỗi batch, khi đăng bài riêng).

## FIX TREO DO LỆCH ĐỒNG HỒ (v22.100.13 — QUAN TRỌNG)
Triệu chứng: log dừng ngay sau "Adscene phần 2/2 | 29139 ký tự", treo >7 phút không báo lỗi.
KHÔNG phải lỗi mạng/origin.

NGUYÊN NHÂN GỐC: trần tốc độ đăng dùng chung trên ổ Z tính giãn cách bằng mtime của file mark.
Hai máy lệch đồng hồ (đo thật: 45 giây) → mtime mark do máy kia ghi nằm ở **TƯƠNG LAI** →
`since_last` ÂM → `_adsconex_take_shared_slot` lặp `while True` mãi mãi → TREO VĨNH VIỄN.

ĐÃ VÁ (3 lớp):
1. Giãn cách tính theo **ĐỒNG HỒ CỦA CHÍNH MÁY** (`_adsconex_local_last_post`).
2. Bỏ qua mark có mtime ở TƯƠNG LAI khi đếm cửa sổ.
3. `ADSCONEX_RATE_SLOT_WAIT_MAX = 25.0` → quá hạn thì giãn cách tại máy thay vì treo.

**NÊN đồng bộ đồng hồ trên MỌI máy chạy tool** (`w32tm /resync`).

## API ADSCONEX — GHI NHỚ
- Auth: `Authorization: Bearer <token>`; base `https://dramanest.gigglelo.com/api`.
- **Đèn báo token sạch = `GET /api/categories`** (200 = OK). KHÔNG dùng POST để test.
- Test tool: `POST {"title":""}` → 422 (không tạo bài). **CHỈ dùng cách này khi cần test.**
- `POST /posts` `mode="chapter"`: tự tách theo marker `CHAPTER N - Title`; intro → mô tả series.
- **`mode=chapter` KHÔNG tự gộp theo `permalink`** — muốn gộp phải truyền `series_id`.
- Sửa bài: `PUT /api/posts/{ID số}` (slug → 405). `next_chapter`/`prev_chapter` phải cùng series.
- **KHÔNG có route xoá**: `DELETE /api/series/{id}` → 404; `DELETE /api/posts/{id}` → 405.
- Rate-limit: 6 bài/phút, cửa sổ 60s, mutex chung trên ổ Z `_adsconex_rate`.

## HOST
- API/đăng bài: `dramanest.gigglelo.com` (**SỐNG**, 401 khi thiếu token = đúng).
- Site hiển thị: `drama.viralstory.biz` (**SỐNG**, 200).
- `usjusticereport.cfx.bz` = **HOST CHẾT** — đã bỏ hẳn khỏi cả 2 tool, đừng thêm lại.

## VIỆC CÒN LẠI (cần xoá TAY trong CMS — API không có route xoá)
**35 series rác** còn trên site (kiểm tra 2026-10-12):
- `[ZZT]` — 14 series (ids: 5305, 5313, 5323, 5395, 5409, 5416, 5432, 5446, ...)
- `[ZZBURST10]` — 10 series (5476–5485)
- `[ZZBURST6]` — 6 series (5462–5467)
- `[ZZCONC3]` — 3 series (5447–5449)
- `[ZZCONC2]` — 2 series (5434, 5435)

Ngoài ra còn ~118 bài test rác (API không có route xoá → xoá tay trong CMS).

## LỆNH HAY DÙNG
```bash
cd C:/Users/Admin/Desktop/Phong_ADung
PY=C:/Users/Admin/AppData/Local/Programs/Python/Python313/python.exe
$PY -m py_compile viet_drama_V22.99_stable_folder.py   # kiem cu phap
$PY release.py 22.100.15 "mo ta thay doi"              # phat hanh (bump + push GitHub)
$PY sync_z.py                                          # copy len Z + doi chieu MD5
```
Chạy tool: double-click `Mo_An.vbs` (ẩn cửa sổ cmd) hoặc `CHAY_Phong_ADung.bat` (xem log).

## BÀI HỌC KỸ THUẬT
- **502 = request quá lớn**, KHÔNG phải token/payload. An toàn ~36KB/request.
- **Số "bẩn" từ model** (`11．11` dấu chấm fullwidth U+FF0E) làm `float()` crash.
  Đã có `safe_float`/`safe_int` (24 chỗ dùng) — **mọi số đọc từ model PHẢI đi qua 2 hàm này**.
- **VBScript KHÔNG có escape `\"`** — muốn 1 dấu `"` phải viết `""`.
- **File tool là LF** — đọc/ghi `newline=""` (git blob cũng LF).
- **`.bat`/`.vbs` cho máy khác: ASCII-only + CRLF + `pause`** (LF + tiếng Việt → tự tắt).
- **`config.yaml`/`.env` ghi bằng .NET `WriteAllText` + `UTF8Encoding($false)`** → không BOM.
- Bộ cài `.bat` **KHÔNG BAO GIỜ ghi đè `.env`** nếu đã tồn tại; thiếu token thì chỉ VÁ THÊM.
- **Test GUI an toàn**: chạy `App()` rồi `destroy()`, so MD5 config trước/sau.
- Tool gửi header Chrome đầy đủ để qua Cloudflare (urllib trần bị `Error 1010`).
