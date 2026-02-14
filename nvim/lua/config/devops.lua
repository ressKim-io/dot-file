-- lua/config/devops.lua
-- DevOps 유틸리티 함수 & 키맵

local map = vim.keymap.set

-- 현재 파일의 전체 경로 복사
map('n', '<leader>yp', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  print('Copied: ' .. path)
end, {desc = 'Copy file path'})

-- 현재 파일의 상대 경로 복사
map('n', '<leader>yr', function()
  local path = vim.fn.expand('%:.')
  vim.fn.setreg('+', path)
  print('Copied: ' .. path)
end, {desc = 'Copy relative path'})

-- Git blame 현재 줄
map('n', '<leader>gb', function()
  local file = vim.fn.expand('%')
  local line = vim.fn.line('.')
  local cmd = string.format('git blame -L %d,%d %s', line, line, file)
  local result = vim.fn.system(cmd)
  print(result)
end, {desc = 'Git blame line'})

-- Base64 인코딩/디코딩
map('v', '<leader>be', function()
  vim.cmd("'<,'>!base64")
end, {desc = 'Base64 encode'})

map('v', '<leader>bd', function()
  vim.cmd("'<,'>!base64 -d")
end, {desc = 'Base64 decode'})

-- JSON <-> YAML 변환
map('v', '<leader>jy', function()
  vim.cmd("'<,'>!yq eval -P")
end, {desc = 'JSON to YAML'})

map('v', '<leader>yj', function()
  vim.cmd("'<,'>!yq eval -o=json")
end, {desc = 'YAML to JSON'})

-- JSON 포맷팅
map('v', '<leader>jf', function()
  vim.cmd("'<,'>!jq .")
end, {desc = 'JSON format'})

map('n', '<leader>jf', function()
  vim.cmd("%!jq .")
end, {desc = 'JSON format (whole file)'})

-- YAML 검증
map('n', '<leader>yv', function()
  local file = vim.fn.expand('%')
  local result = vim.fn.system('yamllint ' .. file)
  if vim.v.shell_error == 0 then
    print('YAML is valid')
  else
    print('YAML validation failed:\n' .. result)
  end
end, {desc = 'Validate YAML'})

-- Kubernetes kubectl apply 현재 파일
map('n', '<leader>ka', function()
  local file = vim.fn.expand('%')
  vim.cmd('!kubectl apply -f ' .. file)
end, {desc = 'kubectl apply current file'})

-- Kubernetes kubectl delete 현재 파일
map('n', '<leader>kd', function()
  local file = vim.fn.expand('%')
  vim.cmd('!kubectl delete -f ' .. file)
end, {desc = 'kubectl delete current file'})

-- Kubernetes 리소스 describe
map('n', '<leader>kD', function()
  local word = vim.fn.expand('<cword>')
  vim.cmd('!kubectl describe ' .. word)
end, {desc = 'kubectl describe'})

-- Kubernetes 리소스 get
map('n', '<leader>kg', function()
  local word = vim.fn.expand('<cword>')
  vim.cmd('!kubectl get ' .. word)
end, {desc = 'kubectl get'})

-- Helm template 미리보기
map('n', '<leader>ht', function()
  local cwd = vim.fn.getcwd()
  vim.cmd('!helm template ' .. cwd)
end, {desc = 'Helm template preview'})

-- Helm lint
map('n', '<leader>hl', function()
  local cwd = vim.fn.getcwd()
  vim.cmd('!helm lint ' .. cwd)
end, {desc = 'Helm lint'})

-- Terraform fmt 현재 파일
map('n', '<leader>tf', function()
  local file = vim.fn.expand('%')
  vim.cmd('!terraform fmt ' .. file)
  vim.cmd('e!')
end, {desc = 'Terraform fmt'})

-- Terraform validate
map('n', '<leader>tv', function()
  vim.cmd('!terraform validate')
end, {desc = 'Terraform validate'})

-- Terraform plan
map('n', '<leader>tp', function()
  vim.cmd('!terraform plan')
end, {desc = 'Terraform plan'})

-- Docker build
map('n', '<leader>db', function()
  local name = vim.fn.input('Image name: ')
  if name ~= '' then
    vim.cmd('!docker build -t ' .. name .. ' .')
  end
end, {desc = 'Docker build'})

-- Docker compose up
map('n', '<leader>dc', function()
  vim.cmd('!docker compose up -d')
end, {desc = 'Docker compose up'})

-- Docker compose down
map('n', '<leader>dC', function()
  vim.cmd('!docker compose down')
end, {desc = 'Docker compose down'})

-- 빠른 실행 (현재 파일)
map('n', '<leader>x', function()
  local file = vim.fn.expand('%')
  local ext = vim.fn.expand('%:e')

  if ext == 'sh' then
    vim.cmd('!bash ' .. file)
  elseif ext == 'py' then
    vim.cmd('!python ' .. file)
  elseif ext == 'js' then
    vim.cmd('!node ' .. file)
  elseif ext == 'go' then
    vim.cmd('!go run ' .. file)
  else
    print('Unsupported file type: ' .. ext)
  end
end, {desc = 'Quick run current file'})
