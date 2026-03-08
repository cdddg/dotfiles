-- Docker Compose filetype detection
vim.filetype.add {
  filename = {
    ['docker-compose.yml'] = 'docker-compose',
    ['docker-compose.yaml'] = 'docker-compose',
  },
  pattern = {
    ['docker%-compose%..*%.ya?ml'] = 'docker-compose', -- docker-compose.prod.yml etc.
  },
}
