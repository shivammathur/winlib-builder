#![no_std]

extern crate libbz2_rs_sys;

use core::panic::PanicInfo;

pub use libbz2_rs_sys::*;

struct StderrWriter;

impl core::fmt::Write for StderrWriter {
    fn write_str(&mut self, value: &str) -> core::fmt::Result {
        unsafe {
            libc::write(2, value.as_ptr().cast(), value.len() as _);
        }

        Ok(())
    }
}

#[panic_handler]
fn panic_handler(info: &PanicInfo) -> ! {
    use core::fmt::Write;

    let _ = StderrWriter.write_str("libbzip2-rs: internal error:\n");
    let _ = StderrWriter.write_fmt(format_args!("{}", info.message()));

    unsafe {
        libc::exit(3);
    }
}
