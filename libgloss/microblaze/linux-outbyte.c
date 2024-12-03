extern int _write2 (int, char *, int);

void outbyte (unsigned char c)
{
	_write(1, &c, 1);
}
