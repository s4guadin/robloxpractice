# upload.ps1 - Publica as mudancas do projeto no GitHub (s4guadin/robloxpractice)
# Uso:  .\upload.ps1 "mensagem do commit"
#
# Requisito: gh CLI autenticado (gh auth login). A autenticacao do push e
# feita pelo helper "gh auth git-credential" (configurado globalmente),
# sem gravar token em nenhum arquivo do projeto.

param(
    [Parameter(Mandatory = $false)]
    [string]$Message = "Atualiza MainUI"
)

$ErrorActionPreference = "Stop"

Write-Host "== Adicionando arquivos..." -ForegroundColor Cyan
git add -A

Write-Host "== Criando commit: $Message" -ForegroundColor Cyan
git commit -m $Message

Write-Host "== Publicando (push) no GitHub..." -ForegroundColor Cyan
git push origin main

Write-Host ""
Write-Host "== Pronto! Rode no Solara:" -ForegroundColor Green
Write-Host 'loadstring(game:HttpGet("https://raw.githubusercontent.com/s4guadin/robloxpractice/main/Practice.lua"))()' -ForegroundColor Yellow
