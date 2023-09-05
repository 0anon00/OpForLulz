KERNEL_VERSION=6.4
KERNEL_SERIES=v6.x
KERNEL_DIRECTORY=linux-$(KERNEL_VERSION)
KERNEL_ARCHIVE=$(KERNEL_DIRECTORY).tar.xz
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/$(KERNEL_SERIES)/$(KERNEL_ARCHIVE)

all: vmlinuz initramfs forlulz.iso

vmlinuz: $(KERNEL_DIRECTORY)
	cd $(KERNEL_DIRECTORY) && make defconfig && make -j`nproc`
	cp $(KERNEL_DIRECTORY)/arch/x86_64/boot/bzImage vmlinuz

$(KERNEL_DIRECTORY):
	wget $(KERNEL_URL)
	tar xf $(KERNEL_ARCHIVE)

initramfs: initfs
	cd initfs/ && find . | cpio -o --format=newc > ../initramfs

initfs:
	git clone https://github.com/landley/toybox | true
	cd toybox && ./mkroot/mkroot.sh
	rm -rf initfs && mv toybox/root/host/fs initfs
	cp init.sh initfs/init

forlulz.iso: vmlinuz initramfs
	mkdir -p iso/boot/grub
	cp vmlinuz initramfs iso/boot/.
	grub-mkrescue -o $@ iso

.PHONY: clean
clean:
	rm -rf vmlinuz initramfs $(KERNEL_DIRECTORY) $(KERNEL_ARCHIVE) \
	toybox iso/boot/vmlinuz initfs \
	iso/boot/initramfs
