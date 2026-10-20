"""Offset representation under a failed initial lseek; no syscall execution."""

MAX_OFFSET = (1 << 63) - 1
IO_BUFFER = 65536


def offset_bounds(offered_bytes, initial_result):
    if type(offered_bytes) is not int or offered_bytes < 0:
        raise ValueError('nonnegative mathematical byte bound required')
    if type(initial_result) is not int or initial_result not in (-1, 0):
        raise ValueError('fresh regular-file lseek result must be -1 or zero')
    return {
        'initial_cached_offset': initial_result,
        'actual_committed_bytes_min': 0,
        'actual_committed_bytes_max': offered_bytes,
        'cached_offset_min': initial_result,
        'cached_offset_max': offered_bytes + initial_result,
        'actual_committed_plus_pending_max': offered_bytes,
        'guard': offered_bytes <= MAX_OFFSET,
        'successful_initial_lseek_required': False,
    }


def flush_step(committed, pending, bias, written):
    """One completed positive write; EINTR/errors have no successful commit."""
    if not (type(bias) is int and bias in (-1, 0)):
        raise ValueError('invalid cached-offset bias')
    if any(type(n) is not int for n in (committed, pending, written)):
        raise ValueError('integer counts required')
    if not (committed >= 0 and 0 < written <= pending <= IO_BUFFER):
        raise ValueError('invalid positive-write prefix')
    if committed + pending > MAX_OFFSET:
        raise ValueError('unrepresented cumulative extent')
    return {'committed': committed + written, 'pending': pending - written,
            'cached': committed + bias + written}


def putch_zero_return_countermodel():
    # Weaker return-count contract allows written=0 even with a full buffer.
    # The actual macro flushes once, then stores at curr before incrementing.
    pending = IO_BUFFER
    written = 0
    store_index = pending - written
    return {'buffer_bytes': IO_BUFFER, 'requested_write_bytes': pending,
            'returned_write_bytes': written, 'putch_store_index': store_index,
            'store_is_in_buffer': 0 <= store_index < IO_BUFFER,
            'observed_target_execution': False,
            'claim': 'countermodel to the weaker interface; not an observed OS defect'}
