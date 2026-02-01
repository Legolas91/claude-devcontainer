# TODO - DevContainer Améliorations

## 1. Devcontainer multi-langage (Go + Python)

### Go
- [ ] S'inspirer de [cloudlabctl](https://github.com/Legolas91/cloudlabctl) pour la config Go
- [ ] Référencer [mcr.microsoft.com/vscode/devcontainers/go](https://mcr.microsoft.com/vscode/devcontainers/go)
- [ ] Installer Go toolchain sans changer l'image de base
- [ ] Ajouter linters Go (golangci-lint, staticcheck, etc.)
- [ ] Configurer VSCode pour Go (extensions, settings)
- [ ] Implémenter standards de codage cloudlabctl:
  - [ ] Configuration % minimum de commentaires
  - [ ] Configuration % minimum de tests unitaires
  - [ ] Pre-commit hooks pour Go

### Python
- [ ] Référencer [mcr.microsoft.com/vscode/devcontainers/python](https://mcr.microsoft.com/vscode/devcontainers/python)
- [ ] Installer Python toolchain
- [ ] Ajouter linters Python (pylint, flake8, black, mypy)
- [ ] Configurer VSCode pour Python (extensions, settings)
- [ ] Implémenter standards de codage:
  - [ ] Configuration % minimum de docstrings
  - [ ] Configuration % minimum de tests unitaires
  - [ ] Pre-commit hooks pour Python

### Configuration commune
- [ ] Mettre à jour Dockerfile avec outils Go et Python
- [ ] Configurer devcontainer.json avec extensions multi-langage
- [ ] Documenter les standards de codage dans README

## 2. Intégration my-claude-code-setup

- [ ] Cloner/référencer [my-claude-code-setup](https://github.com/Legolas91/my-claude-code-setup)
- [ ] Intégrer le script d'initialisation Claude
- [ ] Ajouter dans postCreateCommand ou postStartCommand
- [ ] Tester l'initialisation automatique de la config Claude
- [ ] Documenter le processus d'initialisation

## 3. Image DevContainer précompilée

### Build et archive
- [ ] Créer script de build de l'image
- [ ] Générer l'image Docker complète
- [ ] Exporter l'image en tar.gz
- [ ] Stocker dans `.devcontainer/bin/`

### Configuration pour utilisation sans build
- [ ] Modifier devcontainer.json pour supporter image précompilée
- [ ] Ajouter documentation pour charger l'image tar.gz
- [ ] Tester le chargement depuis archive
- [ ] Script d'import automatique de l'image

### Maintenance
- [ ] Script de mise à jour de l'image
- [ ] Versioning des images (tags)
- [ ] Documentation du processus de rebuild

## 4. Export/Archive du projet

### Script d'archivage
- [ ] Créer script pour générer zip du projet
- [ ] Exclure fichiers temporaires:
  - [ ] node_modules/
  - [ ] .git/ (optionnel)
  - [ ] Fichiers de cache (.cache/, __pycache__/, etc.)
  - [ ] Logs
  - [ ] Fichiers de build
  - [ ] .devcontainer/bin/*.tar.gz (optionnel)
- [ ] Ajouter .zipignore ou équivalent
- [ ] Tester la génération d'archive
- [ ] Documenter l'utilisation du script

### Options avancées
- [ ] Option pour inclure/exclure .git
- [ ] Option pour inclure/exclure images précompilées
- [ ] Génération de checksum (SHA256)
- [ ] Script de déploiement depuis archive

---

## Notes

### Ressources
- [cloudlabctl](https://github.com/Legolas91/cloudlabctl) - Référence standards Go
- [my-claude-code-setup](https://github.com/Legolas91/my-claude-code-setup) - Config Claude
- [mcr.microsoft.com/vscode/devcontainers/go](https://mcr.microsoft.com/vscode/devcontainers/go)
- [mcr.microsoft.com/vscode/devcontainers/python](https://mcr.microsoft.com/vscode/devcontainers/python)

### Ordre d'implémentation suggéré
1. Multi-langage (Go + Python) - base technique
2. Image précompilée - optimisation
3. my-claude-code-setup - intégration outils
4. Export/Archive - utilitaires
