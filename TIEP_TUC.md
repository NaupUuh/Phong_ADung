# TIẾP TỤC — Phong_ADung (Video Story Publisher VV22.99)

> Đọc file này trước khi sửa tool. Cập nhật lại mỗi khi rời tool.

## Trạng thái hiện tại (2026-10-06)
- **Version đang chạy:** v22.100.5
- **Repo GitHub:** https://github.com/NaupUuh/Phong_ADung
- **Thư mục máy:** `Phong_ADung`
- **Cách chạy:** bấm đúp `CHAY_Phong_ADung.bat` (hoặc `viet_drama_V22.99_stable_folder.py`)

## Đã làm xong
- Tách khỏi tool kia: config / crash log / cache riêng, không ghi đè nhau.
- `PROFILE_ID = "V22.99"` ở đầu file — đổi 1 dòng này là tách sang profile khác.
- Đã đưa lên GitHub + cơ chế tự cập nhật (giống News_Clip_Stitcher).
- Nút **⬆ Cập nhật** ở góc trên bên phải cửa sổ: bấm là tự tải bản mới → ghi đè → mở lại.
- `Cai_dat_may_moi.bat` cho máy mới (đã test thật: cài đủ 11 file).
- **Ô "Câu chèn trong tên file"** trong tab Cài đặt: mỗi dòng 1 câu, tool chọn
  ngẫu nhiên 1 câu thay chuỗi `full story` khi đặt tên file. Để trống → quay về
  `full story` như bản cũ.

## Tên file video (định dạng)
```
<caption>;<câu chèn ngẫu nhiên> <link bài không dấu chấm/slash>.mp4
```
Ví dụ thật (đã chạy đúng trên máy):
```
She Whispered Come On, Sasha At 2 AM - Then Her Dog Led Her To The Nursery Door
#SashaTheDog #NurseryNight #DogHero #TwoAM #MotherAndDog;WATCH THE NEXT PART HERE
httpsdrama.viralstory.bizarticle100989.mp4
```
- Giới hạn **219 ký tự** (có từ bản gốc, để an toàn với Windows + ổ mạng).
- Tên quá dài → cắt bớt tiêu đề. Muốn nới thì sửa hằng số giới hạn trong
  `safe_video_filename()` — **cần user quyết** (219 an toàn / 240 đủ ví dụ dài).

## Cơ chế tự cập nhật (đã test thật, PASS)
| File | Việc |
|---|---|
| `version.json` | version + notes + date (nguồn so sánh) |
| `updater.py` | tải zip GitHub → giải nén → ghi đè → backup `_backup_update/` |
| `release.py` | phát hành bản mới: `python release.py <ver> "<mô tả>"` |
| `_backup_update/` | backup tự động trước mỗi lần ghi đè (có thể rollback) |

**Khi có bản mới, máy khác chỉ cần:** mở tool → bấm **⬆ Cập nhật**.

### Bẫy đã gặp: cache version.json của GitHub
`contents?ref=main` và `raw.githubusercontent` đều có thể trả bản CŨ vài giây
sau khi push → bấm Cập nhật ngay sẽ báo "đang là bản mới nhất" (SAI).
**Đã sửa:** updater hỏi commit mới nhất có đụng `version.json`, rồi đọc
`version.json` **ở đúng commit đó** (`?ref=<sha>`) — nội dung theo sha là bất
biến, không dính cache. Chỉ khi cách này lỗi mới rơi về 2 cách cũ.

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

## Tab Adsconex (mới, 2026-10-05) — CHƯA test end-to-end
- Tab **Adsconex** trong GUI + ô chọn **"Net đăng bài"** (SmartTraffic / Adsconex) ở tab chính.
- Ô nhập **Adsconex API Token** che `*` + nút **Edit Key / Hide Key**, nút **Kiểm tra token**, mở API docs.
- Config thêm 7 khoá: `net_provider`, `adsconex_api_key`, `adsconex_base_url`,
  `adsconex_site_host`, `adsconex_category`, `adsconex_author`, `adsconex_apply_image_to_all`.
- `publish_adsconex()` + `publish_current()` (dispatcher) — batch và nút Publish đều đi qua dispatcher.
- Khác SmartTraffic: Adsconex tạo **1 bài riêng mỗi chapter**, link dạng `/blog/<slug>`,
  link lấy **từ response** (KHÔNG tự ghép từ permalink), không gọi `verify_published_chapters` (`?c=N`).
- **Đã verify:** compile OK; dispatcher đúng cả 4 giá trị (`SmartTraffic`/`Adsconex`/`adsconex`/rỗng);
  rename file ra đúng định dạng 219 + link `/blog/<slug>`; GUI dựng đủ tab.
- **CHẶN:** API public Adsconex trả **403 `blogbio_verify_failed` / `verify_status: 502`**.
  Đã chứng minh là **lỗi server** (token rác và token thật cùng lỗi; không token → 401 đúng chuẩn).
  Monitor 78/78 lần đều 403. **Khi API hồi phục:** chạy 1 bài test Net=Adsconex, xác nhận response
  có `posts[]` + link `/blog/<slug>` rồi mới bump version.

- **Category ID lấy ở đâu (2026-10-05):** bảng `/admin/categories` KHÔNG hiện ID.
  Lấy bằng 1 trong 2 cách:
  - Trong tool: tab Adsconex → bấm **"Lấy danh sách"** (cần token) → popup → bấm 1 dòng là điền ID.
  - Thủ công: mở Chrome đã đăng nhập → F12 → Network → lọc `taxonomies` → xem
    `GET /admin/api/v1/taxonomies/categories` (JSON có `id`, `title`, `slug`).
  **Category thật của site:** Story=15, Fighter=14, VintageStyle=13, Athlete=12,
  WomensWrestling=11, ProWrestling=10, AEW=9, WrestlingStar=8, SportsEntertainment=7,
  Sport=6, Entertainment=5, Game=4, Technology=1.
  **Mặc định trong tool = 15 (Story).** API public: `GET /api/categories` (Bearer token).
- **`author` là gì (2026-10-05):** KHÔNG phải tên hiển thị. Là **chuỗi ghép vào đuôi slug**.
  Bằng chứng thật: admin username `aqtn2`, creator name `Admin` → slug bài ra
  `the-corridor-adminqq` (đuôi `adminqq`), field `author` trong post = `null`.
  Để trống thì server tự thêm hậu tố. Điền gì thì điền chuỗi slug-safe (a-z0-9-).

## Việc còn lại
- **ĐÃ QUYẾT (2026-10-05): GIỮ giới hạn 219 ký tự** — user chọn an toàn với Windows
  + ổ mạng, chấp nhận việc tool cắt bớt tiêu đề khi quá dài. **KHÔNG nới lên 240.**
  Đừng đề xuất lại trừ khi user hỏi.
- **ĐÃ QUYẾT (2026-10-05): KHÔNG mã hoá / không che code.** User đã cân nhắc và
  bỏ qua. Đã test thật: PyArmor trial **KHÔNG** làm nổi file 266 KB (`out of
  license`, giới hạn ~32 KB); `.pyc` dễ dịch ngược; đóng gói `.exe` sẽ **làm chết
  nút Cập nhật** (updater ghi file `.py` rồi chạy lại `sys.executable + .py`).
  Repo vẫn để **public** như hiện tại. **Đừng đề xuất lại** trừ khi user hỏi.
- **Chưa rõ nguyên nhân:** file config ADung từng bị ghi đè thành 3 khoá
  (`vilao_api_key` giả `KEY_THAT_CUA_ANH`, `site_id`, `category`) lúc 10:43.
  Config đã tự khôi phục đủ 58 khoá + key thật. Không phải do test của mình.
  Nếu gặp lại: kiểm tra ngay file config trước khi chạy tool.

## Bằng chứng tool chạy ĐÚNG (lần chạy thật 11:44–11:50 ngày 05/10)
Output: `Z:\HQData-2\dũng dùng drama\AQ test\test\Story Outputs\`
- 2/3 video: `status: success`, bài **đã lên net thật** (HTTP 200):
  - `/article/100989` (slug `you-saved-us-the-dog-that-knew`)
  - `/article/100990` (slug `my-son-came-home-black-sedan-fifty-years`)
- Cả 2 file video **đã được đổi tên đúng định dạng** trong folder nguồn.
- 1/3 video: `failed` do server đăng bài trả **502/504 Bad Gateway** (lỗi phía
  máy chủ, KHÔNG phải lỗi tool). Gặp lại thì chạy lại video đó.
- Lưu ý: `chapter_verified: false` trong `publish_result.json` — cần xem lại nếu
  user phàn nàn bài không phân chương.
- Crash log chỉ có 2 dòng `open_output` FileNotFoundError (bấm "Mở output" khi
  thư mục trên ổ Z đã bị xoá) — không ảnh hưởng pipeline.

## Lệnh hay dùng
```
# chạy tool
Phong_ADung\CHAY_Phong_ADung.bat

# kiểm tra có bản mới không (không mở GUI)
python updater.py

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
- Tool dùng chung `site_id` / API key với tool kia (do copy config) nhưng KHÔNG ghi đè nhau.

### Fix 2026-10-05 (v22.100.0)
- **Loi `'_tkinter.tkapp' object has no attribute 'root'`** khi bam "Lay danh sach" category
  -> nguyen nhan: `tk.Toplevel(self.root)` nhung class `App(tk.Tk)` KHONG co attr `self.root`.
  -> FIX: doi thanh `tk.Toplevel(self)` + `win.transient(self)`.
  -> BAI HOC: trong file nay `App` CHINH LA Tk root -> moi Toplevel dung `tk.Toplevel(self)`.
- Da test: popup hien 3 dong, bam Chon -> dien dung ID, bam Dong -> dong cua so, GUI 7 tab OK, khong con crash log.
- **API Adsconex da HOI PHUC** cho token that (popup hien duoc = GET /api/categories tra 200).
  Token rac van 403 `blogbio_verify_failed` nhu cu -> dung lo.
- Da release v22.100.0 + sync Z 13/13 MD5 khop.

### Fix 2026-10-06 (v22.100.5) — CRASH SO BAN TU MODEL ('could not convert string to float')
- **Trieu chung user gap:** dialog loi `could not convert string to float: '11.11'` tai `analyze_with_vision`.
- **ROOT CAUSE:** `float('11.11')` khong the loi -> chuoi that chua **dau cham FULLWIDTH U+FF0E**, nhin y het dau cham thuong. Model Vilao thinh thoang tra so kem ky tu Unicode.
- **FIX:** them `safe_float()` / `safe_int()` o module level: chuan hoa **NFKC** (fullwidth -> ASCII) + bo NBSP/zero-width + doi minus U+2212 + regex `_NUM_RE` cuu ca chuoi lan van ban ('11.11s - 15.20s'). Ap cho **MOI** field so tu model: `time_start/time_end` (batch Vision), `events` dang dict (chuan hoa tai cho), sort event, `_chapter_source_payload` (number/start/end), `nums`, `transcript_slice_for_time`, prompt f-string, `_write_one_chapter` setdefault, heading HTML dang web.
- **Bang chung:** chay lai DUNG code path cu -> ban CU crash y nguyen thong bao user gap, ban MOI chay sach (`start=11.11 end=15.20` deu la float). Test 16 dang so ban (fullwidth, '11.11s', '11,11', '~11.11', range, zero-width, None, dict, list) deu PASS.
- **File:** them ~18 cho `safe_float` + 7 cho `safe_int` moi file. CRLF giu nguyen (LF tran=0), compile OK.
- **Khong doi:** GUI, config, logic nghiep vu. E2E van PASS (12/12 khung co mat, thumb 290x290, cover 760x400).
- **Bai hoc chi tiet:** skill `grok-batch-video-tools` -> `references/dirty-numeric-parse.md`

### Fix 2026-10-06 (v22.100.4) — ANH BIA: THAY DETECTOR MAT (OpenCV 5.x) + UU TIEN CAM XUC
- **Yeu cau:** anh bia phai la anh CO NGUOI/nhan vat, NET nhat co the, cam xuc/drama cang cao cang tot.
- **ROOT CAUSE (quan trong nhat):** OpenCV **5.0.0** da **XOA HAN** `cv2.CascadeClassifier`
  va `cv2.data.haarcascades` -> `FACE_CASCADE = None` -> **tool MUA MAT hoan toan**; logic
  "uu tien anh co nguoi" bi vo hieu, chi con chon theo do net thuan -> anh bia hay ra canh
  KHONG CO NGUOI. (Khong phai loi cua ban cu — do OpenCV nang cap.)
- **FIX:** thay Haar cascade bang **YuNet `cv2.FaceDetectorYN`** (`face_detection_yunet_2023mar.onnx`,
  232 KB) + **model cam xuc** `facial_expression_recognition_mobilefacenet_2022july_int8bq.onnx`.
  - Model **tu tai runtime** ve `~/.video_story_publisher_models` (KHONG commit vao repo);
    URL chinh `media.githubusercontent.com/media/opencv/opencv_zoo/...`, URL du phong raw.
    (Luu y: `raw.githubusercontent` tra ve 131 byte = LFS pointer -> phai dung `media.`.)
  - **Offline fallback**: khong tai duoc model -> in canh bao, quay ve cham do net, KHONG crash.
  - **Thread-local detector** (`_FACE_TLS`) vi `extract_frames` chay ThreadPool.
- **ADung TRUOC DAY KHONG CO `find_person_thumbnail_frame`** (DHue moi co) -> ban va nay
  **THEM MOI** ham nay + noi vao luong `attach_local_images` (quet lai 24 moc/video khi
  cac khung da lay khong co mat nao).
- **Bang diem moi (thu tu uu tien ro rang):** CO NGUOI > DO NET > CAM XUC/DRAMA.
  `FACE_GATE=3600` > `SHARP_WEIGHT(3300)+DRAMA_WEIGHT(320)` => **moi khung co mat LUON thang
  khung khong mat**. Trong nhom co mat: mat to + o giua + drama cao thang.
  (Ban va v1 tung nhan `score *= 0.35` khi mo -> nhan ca phan thuong "co nguoi" -> khung mo
  co mat thua khung net khong mat. Da sua o v2: TACH thuong co nguoi ra khoi phat do net.)
- **Nhan cam xuc** (thu tu model tra ve): `angry, disgust, fearful, happy, neutral, sad, surprised`.
  Tien xu ly = **align 5 landmark STD + normalize**. `EMOTION_DRAMA`: angry/fearful 1.0,
  sad 0.92, surprised 0.82, disgust 0.68, happy 0.55, neutral 0.12.
- **Cat vuong 290x290 theo KHUON MAT** (`make_social_thumbnail`): mat ~45% tu tren xuong ->
  khong cat tran. Cover web 760x400 (`make_story_cover`) giu nguyen.
- **Hieu nang (do that, 84 khung/video):** `max_width=480` -> +2.1s/video so voi ban cu
  (trump 8.9->11.2s, Debt 8.4->10.3s). Chi rieng buoc quet khung; cac buoc khac (Whisper/TTS/render)
  ton hang phut nen khong dang ke. **Da thu `max_width=384`: nhanh hon 30% NHUNG lech khung
  chon o 1/4 video -> KHONG dung** (uutien chat luong anh bia). Giu 480.
- **E2E PASS:** 12/12 khung co mat, `find_person_thumbnail_frame` tim thay, thumbnail web
  290x290 + cover 760x400 dung kich thuoc; **thread-safety PASS** (4 luong song song, 0 loi).
- **Backup ban cu:** `_backup_old/*.py.bak` (git + sync Z + updater deu bo qua nho `*.bak`).
- **Bump:** `APP_VERSION` 22.100.3 -> **22.100.4**.

### Fix 2026-10-05 (v22.100.3) — GOM O "CAU CHEN" VAO TAB KICH BAN & PROMPT
- **Yeu cau:** o "Cau chen trong ten file" nam rieng o vung Source (tren notebook) lam trang cao,
  phai cuon nhieu. Gom xuong tab "Kich ban & Prompt" thanh **3 o canh nhau**.
- **Cach lam:** xoa label+editor khoi `source` (bo row=5/6); them `phrase_panel` (LabelFrame
  "Câu chèn trong tên file") vao `prompt_tab` column=2, `columnconfigure(2, weight=1,
  uniform="editors")`. `script_panel` doi padx `(5,0)` -> `(5,5)`.
- **Giu nguyen bien:** `self.filename_phrase_editor` — ham save `cfg["filename_phrase_list"]`
  va `pick_filename_phrase()` khong doi.
- **Chieu cao:** ADung notebook prompt_tab = 240 (panel h=220); DHue = 190 (panel h=180).
  Do bang `probe_h.py`: ca 3 panel deu `reqh < h` => khong bi cat.
- **Test:** `smoke_3panel.py` (ADung) + `smoke_3panel_dhue.py` (DHue) — 3 panel dung cot 0/1/2,
  editor mapped, save roundtrip dung.
- **Luu y CRLF:** file dung CRLF; `patch` voi khoi nhieu dong hay truot — cat nho tung khoi.

### Fix 2026-10-05 (v22.100.2) — CON LAN CHUOT
- **Trieu chung:** lan chuot o vung nen (ngoai cac o nhap) KHONG cuon trang; chi cuon duoc khi
  tro nam trong o Text/Listbox. Phai keo thanh truot tay moi xuong duoc.
- **Nguyen nhan:** `tk.Canvas` KHONG tu an su kien `<MouseWheel>` (khac `Text`/`Listbox`).
  Trang chi cuon duoc neu tro tinh co nam tren widget co scroll rieng -> vung nen chet.
- **FIX (3 phan):**
  1. Luu canvas: `self.content_canvas = canvas` (dong ~4167).
  2. `self.bind_all("<MouseWheel>", self._on_mousewheel, add="+")` (dong ~4184).
  3. Them `_on_mousewheel()` + `_scroll_content()` (~dong 4621):
     - `winfo_containing()` -> di nguoc chuoi `master`; gap `Text`/`Listbox` -> `return None`
       (nhuong quyen cho o do tu cuon).
     - Chi cuon khi diem nam TRONG `content_canvas` (chan `bind_all` cuon nham khi popup mo).
     - `winfo_containing()` tra `None` -> fallback so sanh toa do voi khung canvas.
     - Het scroll (`first<=0 and last>=1`) -> `return None`, khong an su kien vo ich.
- **BAI HOC:** moi `tk.Canvas` lam khung cuon deu PHAI bind `<MouseWheel>` thu cong;
  dung `bind_all` + kiem tra widget duoi con tro de khong giat quyen cua `Text`/`Listbox`.
- Da test 5 kich ban: ngoai o nhap (xuong+len) OK, trong Text nhuong quyen OK,
  trong popup khong cuon canvas chinh OK, fallback `winfo_containing=None` OK, khong crash log.
- Da release v22.100.2 + sync Z 13/13 MD5 khop.

### Fix 2026-10-05 (v22.100.1) — TREO "Dang chuan bi..."
- **Trieu chung:** bam chay, qua 1-2 phut van hien "Dang chuan bi...", Log TRONG hoan toan.
- **Nguyen nhan (faulthandler dump):** thread worker ket trong `openai ... chat.completions.create`
  -> httpx `read`. Client o `StoryPipeline.__init__` KHONG set timeout nen dung default cua SDK:
  **read=600s + max_retries=2** => 1 request Vilao bi treo co the giu tool ~30 phut, khong in log gi.
  (Log trong vi `check_model_access()` chay TRUOC moi dong log dau tien.)
- **FIX:**
  1. `StoryPipeline.__init__`: them `timeout=180.0, max_retries=0` cho OpenAI client.
  2. `run()`: them `_log("START: Preparing (kiem tra model Vilao)")` TRUOC `check_model_access()`
     va `DONE: Preparing` sau -> khong bao gio im lang nua.
  3. Nut test model (dong ~4917): them `timeout=60.0, max_retries=0`.
- **Da verify:** client.timeout=180.0 | max_retries=0; log "START: Preparing" xuat hien NGAY
  (truoc khi cho API) => het hien tuong dong bang im lang.
- **Luu y:** `check_model_access` binh thuong chi ~3.6s (Vision gpt-6-sol 3.4s, Writer deepseek-v4.1-flash 0.2s).
- Da release v22.100.1 + sync Z 13/13 MD5 khop.
