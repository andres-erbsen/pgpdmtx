# Dependencies

- `gpg`
- `paperkey`
- `dmtx-utils`
- `pdflatex`

# Usage

To create a backup, run `bash pgpdmtx.sh $KEY_ID` and print `textput.pdf`. To restore, scan the page to `scan.pdf` and run `dmtxread scan.pdf | paperkey --pubring ~/.gnupg/pubring.gpg > restored-key.gpg` (your public key has to be in your keyring already). 

# Example

[here](https://dl.dropboxusercontent.com/u/1722762/pgpdmtx.pdf)

# License

GPLv3+ but negotiable, especially with Open Source projects.
