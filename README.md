# CCHL Tech Utilities Installer

Public distribution repository for CCHL Tech Utilities.

This repository contains the freely downloadable Windows bootstrap installer and will contain encrypted manager/catalog/utility release assets and SHA-256 checksum files. It intentionally contains no private source, GitHub credentials, distribution password, or decrypted package content.

## Planned installation flow

1. Download the bootstrap installer and its SHA-256 checksum from a release.
2. Verify the checksum.
3. Run the installer as the intended Windows user.
4. Enter the CCHL distribution password supplied through an authorized internal channel.
5. The installer validates the password by decrypting the manager, then stores it protected with Windows DPAPI for that user.

The installed graphical manager does not require a later GitHub sign-in or application password. It offers user-initiated update checks.

## Security note

This is shared-password distribution, not individual identity or revocation. Anyone who receives the distribution password can decrypt the public encrypted assets. A password rotation requires a new release and a reinstall for each Windows user.
