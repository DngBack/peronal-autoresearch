---
name: research-synthesis
description: Tổng hợp kết quả thành bảng so sánh và viết/cập nhật draft paper (draft/paper.md). Dùng khi đã đủ thí nghiệm theo success criteria.
---

# Research Synthesis

Dùng skill này khi **đã đủ thí nghiệm** (theo success criteria trong research_brief hoặc heuristic): tổng hợp số liệu thành **bảng so sánh**, rồi điền hoặc cập nhật **draft/paper.md** (method, experiments, results, discussion, conclusion).

## Khi nào dùng

- research_plan.md ghi "đủ evidence để viết kết luận" hoặc đã đạt success criteria (vd đủ số ablations, đủ bảng).
- User nói "tổng hợp kết quả", "viết draft paper", "tạo bảng so sánh và draft".
- Sau vòng lặp research-experiment, bước tiếp theo là synthesis (spec phase 4.3).

## Instructions

1. **Thu thập số liệu**
   - Đọc `results.tsv` (commit, val_bpb, memory_gb, status, description).
   - Đọc `research_plan.md` (danh sách thí nghiệm đã chạy, nhận định).
   - Bỏ qua dòng status = `crash` hoặc `discard` nếu không muốn đưa vào bảng chính (có thể ghi trong appendix hoặc footnote).

2. **Tạo bảng so sánh**
   - Bảng chính (markdown): ít nhất các cột: **Experiment** (tên), **val_bpb**, **memory_gb** (hoặc peak_vram_mb), **Mô tả thay đổi** (ngắn).
   - Hàng: baseline + từng thí nghiệm đã keep / đáng so sánh.
   - Lưu bảng vào:
     - Trong `research_plan.md` — phần **Results summary** (hoặc "Bảng so sánh").
     - Và/hoặc file riêng `draft/results_table.md` nếu muốn tách.
   - Mục đích: human và agent đều dựa vào bảng này để đánh giá và viết draft.

3. **Tạo hoặc cập nhật draft/paper.md**
   - Đường dẫn: `draft/paper.md` (hoặc `draft/paper.tex` nếu chọn LaTeX).
   - Cấu trúc nội dung:
     - **Abstract:** 2–4 câu tóm tắt mục tiêu, method ngắn, kết quả chính, kết luận.
     - **1. Introduction / Goal:** Mục tiêu nghiên cứu (từ research_brief), câu hỏi/giả thuyết.
     - **2. Method:** Codebase (autoresearch/nanochat-style), metric (val_bpb), time budget, setup (GPU, batch, v.v.).
     - **3. Experiments:** Mô tả từng thí nghiệm (baseline + ablations); **chèn bảng so sánh** (từ bước 2).
     - **4. Results & Discussion:** Giải thích số liệu, so sánh với baseline, nhận định ngắn (từ research_plan).
     - **5. Conclusion:** Kết luận chính, hạn chế, hướng mở (nếu có).
     - **References:** (tùy chọn) Paper/URL đã dùng hoặc gợi ý trong research_brief.
   - Điền nội dung và số liệu từ bảng; không cần văn phong hoàn chỉnh, ưu tiên đúng số và rõ ý. Human có thể chỉnh style sau.

4. **Cập nhật research_plan.md**
   - Phần "Bước tiếp theo" hoặc "Nhận định": ghi "Đã tổng hợp bảng và draft paper tại draft/paper.md."
   - (Tùy chọn) Ghi đường dẫn tới bảng và draft để dễ tìm.

## Output

- **research_plan.md:** Có phần Results summary với bảng so sánh (markdown).
- **draft/paper.md:** Có đủ các section trên, trong đó section Experiments chứa bảng so sánh và mô tả thí nghiệm.
- (Tùy chọn) File `draft/results_table.md` chỉ chứa bảng, nếu tách riêng.

## Lưu ý

- Bảng phải dùng số liệu từ results.tsv và research_plan (nhất quán).
- Nếu chưa có thư mục `draft/`, tạo và đặt `draft/paper.md` trong đó.
- Agent không cần viết references đầy đủ kiểu academic; có thể để "—" hoặc list URL ngắn nếu đã dùng research-read-external.
