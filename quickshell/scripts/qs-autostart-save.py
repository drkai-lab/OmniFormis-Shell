import sys, json, os

if len(sys.argv) < 2:
    sys.exit(1)

new_order = json.loads(sys.argv[1])
file_path = '/home/boing/Dotfiles/hypr/modules/autostart.lua'

if not os.path.exists(file_path):
    sys.exit(1)

with open(file_path, 'r') as f:
    lines = f.read().splitlines()

start_idx = -1
end_idx = -1
for i, line in enumerate(lines):
    if 'hl.on("hyprland.start"' in line:
        start_idx = i
    if line.strip() == 'end)' and start_idx != -1:
        end_idx = i
        break

if start_idx != -1 and end_idx != -1:
    new_lines = lines[:start_idx+1]
    for item in new_order:
        cmd = item.get('cmd', '')
        enabled = item.get('enabled', True)
        if cmd:
            prefix = "    hl.exec_cmd" if enabled else "    -- hl.exec_cmd"
            new_lines.append(f'{prefix}("{cmd}")')
    new_lines.extend(lines[end_idx:])
    
    with open(file_path, 'w') as f:
        f.write('\n'.join(new_lines) + '\n')
