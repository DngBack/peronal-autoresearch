---
name: research-setup
description: Khởi tạo research run — đọc repo và research_brief, tạo research_plan.md với mục tiêu và danh sách thí nghiệm dự kiến. Dùng khi bắt đầu research theo spec Research Agent.
---

# Research Setup

Dùng skill này khi user yêu cầu **bắt đầu research** hoặc **setup theo research_brief**: đọc repo, phân tích mục tiêu từ `research_brief.md`, tạo hoặc cập nhật `research_plan.md` với kế hoạch thí nghiệm.

## Khi nào dùng

- User nói "bắt đầu research", "setup research", "đọc research_brief và lên kế hoạch", "khởi tạo theo research_brief".
- Cần tạo `research_plan.md` lần đầu hoặc reset kế hoạch cho một research brief mới.
- Workflow Research Agent (spec `specs/research-agent-spec.md`) — bước khởi tạo (phase 4.1).

## Instructions

1. **Đọc research brief**
   - Mở `research_brief.md` (cùng repo).
   - Trích: mục tiêu nghiên cứu (bắt buộc), time_budget_minutes (nếu có), success criteria (nếu có), gợi ý đọc thêm (URL/papers), ràng buộc bổ sung.

2. **Đọc repo (in-scope)**
   - `README.md` — ngữ cảnh repo.
   - `prepare.py` — constants (MAX_SEQ_LEN, TIME_BUDGET, EVAL_TOKENS), dataloader, `evaluate_bpb`; không sửa trừ khi brief cho phép.
   - `train.py` — model, optimizer, training loop; file agent sẽ sửa cho thí nghiệm.
   - `specs/research-agent-spec.md` — quy trình, artifacts, bảng so sánh, draft paper.
   - (Tùy chọn) `program.md` nếu tồn tại.

3. **Đọc thêm (nếu có trong brief)**
   - Nếu research_brief có mục "Gợi ý đọc thêm" với URL hoặc tài liệu: dùng skill **research-read-external** (hoặc fetch/tóm tắt) để nắm related work / baseline / trick trước khi viết plan.

4. **Tạo research_plan.md**
   - Cấu trúc:
     - **Mục tiêu:** Tóm tắt 1–2 câu từ research_brief.
     - **Giả thuyết / câu hỏi / theme:** Rút ra từ mục tiêu.
     - **Time budget:** Ghi rõ (giây hoặc phút); nếu brief có `time_budget_minutes` thì dùng, không thì mặc định 5 phút (300s).
     - **Success criteria:** Nếu brief có thì chép lại; không thì ghi "Theo heuristic: đủ thí nghiệm để lập bảng so sánh và viết draft."
     - **Danh sách thí nghiệm (planned):** Ít nhất:
       - `baseline` — chạy train.py hiện tại, không đổi code.
       - 2–4 thí nghiệm dự kiến (tên ngắn + mô tả thay đổi, vd "ReLU² → GELU", "depth=4", "LR 0.02"). Trạng thái = `pending`.
     - **Results summary (bảng):** Để trống hoặc placeholder "Sẽ điền sau khi chạy."
     - **Nhận định / Bước tiếp theo:** "Chạy baseline rồi lần lượt các thí nghiệm pending."
   - Lưu file tại root repo: `research_plan.md`.

5. **Xác nhận với user (tùy chọn)**
   - Nếu user chưa nói "chạy autonomous": tóm tắt plan và hỏi "OK để bắt đầu chạy baseline và vòng lặp thí nghiệm?".
   - Nếu user đã nói "cứ chạy" / "autonomous": bỏ qua, chuyển sang dùng skill **research-experiment** cho run đầu (baseline).

## Output

- File `research_plan.md` đã tạo/cập nhật, có mục tiêu, danh sách thí nghiệm planned, success criteria và time budget rõ ràng.
- (Tùy chọn) Gợi ý bước tiếp: "Chạy baseline với `uv run train.py` rồi ghi kết quả vào results.tsv và cập nhật plan."

## Lưu ý

- Không sửa `train.py` hay code trong bước setup; chỉ tạo plan.
- Nếu `results.tsv` chưa tồn tại, có thể tạo với header: `commit	val_bpb	memory_gb	status	description` (tab-separated). Hoặc để skill **research-experiment** tạo khi chạy run đầu.
