# Research Agent Setup

Repo này chứa **bộ setup Research Agent**: template research brief, Cursor skills, spec và script để gắn vào **bất kỳ repo thí nghiệm** (autoresearch, nanochat, hoặc repo train/eval tương tự). Sau khi clone và chạy setup, repo thí nghiệm của bạn sẽ có đủ file và thư mục để dùng Cursor agent theo mục tiêu nghiên cứu (giả thuyết → thí nghiệm → bảng so sánh → draft paper).

## Yêu cầu

- Repo thí nghiệm có ít nhất: script train (vd `train.py`), cách chạy (vd `uv run train.py`), và metric (vd val_bpb). Có thể có `prepare.py`, `program.md` hoặc tương đương.
- [Cursor](https://cursor.com) (hoặc IDE hỗ trợ Agent + skills).
- Bash (để chạy `setup.sh`).

## Cách dùng: Clone và setup cho repo experiment

### 1. Clone repo Research Agent

**Cách A — Clone vào trong repo thí nghiệm (khuyến nghị):**

```bash
cd /path/to/your-experiment-repo
git clone https://github.com/YOUR_USER/research-agent.git research-agent
```

**Cách B — Clone ra ngoài, rồi chạy setup trỏ vào repo thí nghiệm:**

```bash
git clone https://github.com/YOUR_USER/research-agent.git
cd research-agent
./setup.sh /path/to/your-experiment-repo
```

### 2. Chạy setup

Từ **thư mục gốc repo thí nghiệm**:

```bash
cd /path/to/your-experiment-repo
bash research-agent/setup.sh
```

Hoặc nếu bạn clone research-agent ra ngoài (cách B):

```bash
./research-agent/setup.sh /path/to/your-experiment-repo
```

Setup sẽ:

- Tạo/copy **research_brief.md** (template) vào root repo thí nghiệm (nếu chưa có).
- Copy **spec** vào `specs/research-agent-spec.md`.
- Copy **Cursor skills** (research-setup, research-experiment, research-synthesis, research-read-external) vào `.cursor/skills/`.
- Tạo thư mục **draft/** (và `.gitkeep` nếu cần).
- In hướng dẫn tích hợp **program.md** (bạn có thể tự thêm đoạn Research Agent mode).

### 3. Tùy chọn: thêm Research Agent vào program.md

Nếu repo thí nghiệm có `program.md`, mở file **research-agent/integration/program-snippet.md** và chép nội dung vào đầu `program.md` (hoặc chỗ phù hợp) để agent biết dùng research_brief và các skills. Có thể chạy:

```bash
# Xem nội dung cần thêm
cat research-agent/integration/program-snippet.md
```

Rồi paste vào program.md thủ công.

### 4. Bắt đầu research

1. Điền **research_brief.md** trong repo thí nghiệm (ít nhất mục tiêu nghiên cứu).
2. Mở repo thí nghiệm trong Cursor, nhắc agent: *"Đọc research_brief và bắt đầu research"* (hoặc *"setup research theo research_brief"*).
3. Agent dùng skill **research-setup** → tạo **research_plan.md** → rồi lặp **research-experiment** (chạy baseline, các thí nghiệm, ghi results) → khi đủ **research-synthesis** (bảng so sánh + **draft/paper.md**).

## Cấu trúc repo Research Agent (repo này)

```
research-agent/
├── README.md
├── setup.sh
├── spec/
│   └── research-agent-spec.md
├── template/
│   └── research_brief.md
├── skills/
│   ├── research-setup/
│   │   └── SKILL.md
│   ├── research-experiment/
│   │   └── SKILL.md
│   ├── research-synthesis/
│   │   └── SKILL.md
│   └── research-read-external/
│       └── SKILL.md
└── integration/
    └── program-snippet.md
```

Sau khi setup, repo thí nghiệm sẽ có thêm (ít nhất):

- `research_brief.md`
- `specs/research-agent-spec.md`
- `.cursor/skills/` (4 skills)
- `draft/` (thư mục)

## Cập nhật

Khi bạn kéo bản mới của research-agent (vd `git pull` trong `research-agent/`), chạy lại `bash research-agent/setup.sh` với tùy chọn `--force` nếu muốn ghi đè template và spec (skills vẫn merge, không xóa skill khác):

```bash
bash research-agent/setup.sh --force
```

## License

MIT (hoặc giữ cùng license với repo thí nghiệm của bạn).
