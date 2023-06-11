#include <ruby.h>
#include <ruby/io.h>

#ifdef HAVE_RB_IO_DESCRIPTOR
#	define my_fileno(io) rb_io_descriptor(io)
#else /* Ruby <3.1 */
static int my_fileno(VALUE io)
{
	rb_io_t *fptr;

	GetOpenFile(io, fptr);

	if (fptr->fd < 0)
		rb_raise(rb_eIOError, "closed stream");
	return fptr->fd;
}
#endif /* Ruby <3.1 !HAVE_RB_IO_DESCRIPTOR */
