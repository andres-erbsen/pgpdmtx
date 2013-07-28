#!/bin/bash
bytes=$(gpg --export-secret-key "$1" | paperkey --output-type raw | wc -c)
fingerprint=$(gpg --fingerprint "$1" | grep = | sed 's:.*Key fingerprint = ::')
n=$((($bytes+1555)/1556))
barcodesize=$((($bytes+$n-1)/$n))
date=$(date +"%Y-%m-%d")

echo "Generating $n barcodes of $barcodesize bytes each (total $bytes)."

for i in $(seq 0 $((n-1))); do
    gpg --export-secret-key "$1" |
        paperkey --output-type raw |
        tail -c "+$((1+($i*$barcodesize)))" |
        head -c "$barcodesize" |
        dmtxwrite -e 8 -f PDF > $((i+1)).pdf
done

# diff <(gpg --export-secret-key "$1" | paperkey --output-type raw) <(ls *.pdf | xargs dmtxread)

(
cat << EOF
\documentclass{minimal}
\renewcommand\normalsize{\fontsize{8pt}{10pt}\selectfont}
\newcommand\large{\fontsize{10pt}{12pt}\selectfont}
\setlength{\textheight}{10in}
\usepackage{graphicx}
\begin{document}
\newcommand{\pageheader}{\normalsize
\begin{enumerate}
\item PGP secret key extracted with paperkey 1.3 by David Shaw, split to chunks and encoded as \texttt{Data Matrix} barcodes.
\item File format:
\item a) 1 octet:  Version of the paperkey format (currently 0).
\hfill b) 1 octet:  OpenPGP key or subkey version (currently 4)
\item c) n octets: Key fingerprint (20 octets for a version 4 key or subkey)
\hfill d) 2 octets: 16-bit big endian length of the secret data
\item e) n octets: Secret data: a partial OpenPGP secret key or subkey packet as
             specified in RFC 4880, starting with the string-to-key usage
             octet and continuing until the end of the packet.
\item Repeat fields b through e as needed to cover all subkeys.
\item To recover a secret key without using the paperkey program, use the
key fingerprint to match an existing public key packet with the
corresponding secret data from the paper key.  Next, append this secret
data to the public key packet.  Finally, switch the public key packet tag
from 6 to 5 (14 to 7 for subkeys).  This will recreate the original secret
key or secret subkey packet.  Repeat as needed for all public key or subkey
packets in the public key.  All other packets (user IDs, signatures, etc.)
may simply be copied from the public key.
\end{enumerate}
}

EOF
for i in $(seq $n); do
    echo "\clearpage \centerline{\large PGP secret key \texttt{$fingerprint} on \texttt{$date}, chunk $i/$n}"
    echo "\vfill \centerline{\includegraphics[width=\textwidth]{$i.pdf}} \vfill \pageheader"
done
echo "\end{document}"
) | pdflatex

if ! diff <(gpg --export-secret-key "$1" | paperkey --output-type raw) <(dmtxread texput.pdf); then
    echo "Could not recover key from barcodes pdf, aborting :(" >&2
    exit 1
else
    echo "Barcodes in texput.pdf represent the key :)"
fi
