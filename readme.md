# Dependencies

- `gpg`
- `paperkey`
- `dmtx-utils`

# Usage

To create a backup, run `bash pgpdmtx.sh $KEY_ID` and print `textput.pdf`. To restore, scan the page to `scan.pdf` and run `dmtxread scan.pdf | paperkey --pubring ~/.gnupg/pubring.gpg > restored-key.gpg` (your public key has to be in your keyring already).

# License

GPLv3+ but negotiable, especially with Open Source projects.
