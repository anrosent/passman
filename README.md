passman
===

PassMan is a password manager that uses GPG to store your passwords encrypted at rest using a single "master" password, with a command-line interface that lets you retrieve decrypted passwords to your clipboard. No passwords in plaintext at rest or in your terminal window, ever!

# Usage
## Viewing your password registry
```bash
$ passman
PassMan Registry:
fb
github
hn
```
## Storing a password
```bash
$ passman -s myspace
Enter your password, followed by [ENTER]:
*******
Password myspace successfully encrypted and store
```

## Retrieving a password
```bash
$ passman myspace
Enter your master passphrase
*******
The password for myspace has been placed on your clipboard!
```

# TODO:

- Tab completion for retrieval
- Use gpg-agent so you don't have to input master pass on every retrieval
- Store usernames too
