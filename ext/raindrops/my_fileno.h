#include <ruby.h>
#include <ruby/io.h>

#ifdef HAVE_RB_IO_DESCRIPTOR
#	define my_fileno(io) rb_io_descriptor(io)
#else /* Ruby <3.1 */
static int my_fileno(VALUE io)
{
	rb_io_t *fptr;

	GetOpenFile(io, fptr);
	rb_io_check_closed(fptr);

	return fptr->fd;
}
#endif /* Ruby <3.1 !HAVE_RB_IO_DESCRIPTOR */
