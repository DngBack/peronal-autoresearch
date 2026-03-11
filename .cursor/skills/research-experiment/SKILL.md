---
name: research-experiment
description: Chọn thí nghiệm, sửa code (train.py hoặc nhiều file theo spec), chạy train, ghi results.tsv và cập nhật research_plan.md. Một bước trong vòng lặp thí nghiệm Research Agent.
---

# Research Experiment (One Step)

Dùng skill này cho **một bước** trong vòng lặp thí nghiệm: chọn một thí nghiệm (pending hoặc mới), sửa code, chạy, ghi nhận, cập nhật plan. Lặp lại skill này cho từng run cho đến khi đạt success criteria hoặc user dừng.

## Khi nào dùng

- Đã có `research_plan.md` (sau research-setup hoặc sau bước trước).
- Cần chạy baseline (run đầu không đổi code) hoặc chạy một thí nghiệm đã planned / mới nghĩ ra.
- User nói "chạy thí nghiệm", "chạy baseline", "chạy tiếp ablation X", hoặc workflow đang ở experiment loop.

## Instructions

1. **Đọc research_plan.md**
   - Xác định thí nghiệm tiếp theo: một mục trạng thái `pending` hoặc "baseline" chưa chạy.
   - Nếu không còn pending: đánh giá đã đủ success criteria chưa; nếu đủ → chuyển sang skill **research-synthesis**. Nếu chưa đủ → đề xuất 1–2 thí nghiệm mới (tên + mô tả) và thêm vào plan với trạng thái `pending`.

2. **Sửa code (trừ baseline)**
   - **Baseline:** Không sửa gì; đảm bảo `train.py` đang ở trạng thái sạch (vd đúng branch, không thay đổi chưa commit).
   - **Thí nghiệm khác:** Sửa theo mô tả trong plan:
     - Phạm vi: chủ yếu `train.py` (model, optimizer, hyperparameters, training loop); có thể thêm/sửa file trong `experiments/` hoặc script phân tích nếu plan yêu cầu.
     - Không sửa `prepare.py` trừ khi research_brief cho phép.
     - Không thêm dependency trừ khi brief cho phép.
   - Commit (optional nhưng nên làm để keep/discard sau): `git add -A && git commit -m "exp: <tên thí nghiệm ngắn>"`.

3. **Chạy train**
   - Lệnh: `uv run train.py > run.log 2>&1` (redirect toàn bộ output).
   - Timeout: Nếu repo có TIME_BUDGET (vd 300s), tổng thời gian run nên < 2× TIME_BUDGET (tối đa ~20 phút); nếu quá thì kill và coi run failed.
   - Đợi chạy xong (hoặc crash).

4. **Đọc kết quả**
   - `grep "^val_bpb:\|^peak_vram_mb:" run.log` (hoặc tương đương) để lấy val_bpb và peak_vram_mb.
   - Nếu không có output → run crash: `tail -n 50 run.log` (hoặc hơn) để lấy stack trace; ghi status = `crash`, val_bpb = 0, memory_gb = 0.

5. **Ghi nhận**
   - **results.tsv:** Thêm một dòng (tab-separated): `commit	val_bpb	memory_gb	status	description`.
     - commit = short hash (7 ký tự) hoặc "n/a".
     - val_bpb = số từ log (hoặc 0 nếu crash).
     - memory_gb = peak_vram_mb / 1024, làm tròn .1f (hoặc 0 nếu crash).
     - status = `keep` | `discard` | `crash`.
     - description = tên thí nghiệm + mô tả ngắn (vd "baseline" hoặc "ReLU² → GELU").
   - **research_plan.md:** Cập nhật mục tương ứng: trạng thái thí nghiệm → `done` hoặc `failed`; ghi val_bpb, peak_vram (hoặc crash) vào mục đó; thêm 1–2 câu nhận định ngắn nếu cần.

6. **Đánh giá & quyết định**
   - So sánh với baseline (và các run trước): val_bpb thấp hơn = tốt hơn.
   - **Keep:** Nếu kết quả tốt hơn (hoặc bằng nhưng đơn giản hơn) → giữ commit, không revert.
   - **Discard:** Nếu tệ hơn hoặc crash → `git reset --hard HEAD~1` (hoặc về commit trước) để code trở lại trạng thái trước thí nghiệm này.
   - Cập nhật "Nhận định / Bước tiếp theo" trong research_plan: thí nghiệm tiếp theo là gì, hoặc "đủ evidence → chuyển synthesis".

7. **Lặp hoặc chuyển phase**
   - Nếu còn thí nghiệm pending và chưa đạt success criteria → lặp lại từ bước 1 (chọn thí nghiệm tiếp).
   - Nếu đã đạt success criteria (hoặc heuristic đủ) → chuyển sang skill **research-synthesis** (tổng hợp bảng, draft paper).

## Output

- results.tsv có thêm 1 dòng.
- research_plan.md được cập nhật (trạng thái, số liệu, nhận định).
- Code ở trạng thái "best so far" (sau keep/discard).
- (Tùy chọn) Thông báo ngắn: "Đã chạy X; val_bpb = ...; [keep|discard]. Bước tiếp: ..."

## Lưu ý

- Không hỏi user "có tiếp tục không?" trong vòng lặp; chỉ dừng khi đạt criteria hoặc user yêu cầu dừng.
- Time budget: nếu research_brief có `time_budget_minutes`, repo cần hỗ trợ override TIME_BUDGET (env hoặc config); agent ghi trong plan để lần chạy dùng đúng budget.
