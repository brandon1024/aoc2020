#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/kdev_t.h>
#include <linux/cdev.h>
#include <linux/slab.h>
#include <linux/uaccess.h>

// -- kernel module initialization --
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Brandon Richardson");
MODULE_DESCRIPTION("Solution for day 3 of 2020 Advent of Code");
MODULE_VERSION("0.0.1");

static int device_file_major_num = -1;
static const char device_name[] = "aoc2020d3";
static dev_t device_no;
static struct class *p_class;

static int device_release(struct inode *, struct file *);
static ssize_t device_file_write(struct file *, const char __user *, size_t, loff_t *);

static struct file_operations fops = {
	.owner = THIS_MODULE,
	.write = device_file_write,
	.release = device_release
};

// -- puzzle solution --
#define OPEN_TILE '.'
#define TREE_TILE '#'

#define CEIL(x, y) ((x) / (y) + ((x) % (y) != 0))

static ssize_t line_len = -1;
static size_t lines = 0;
static unsigned long **puzzle = NULL;

static int append_input_line(const char *buffer, size_t len)
{
	unsigned long *tiles;
	size_t i;

	lines++;

	// each line in the puzzle is a bitmap and can be manipulated using standard linux API
	puzzle = krealloc(puzzle, lines * (sizeof(unsigned long *)), GFP_KERNEL);
	puzzle[lines - 1] = kcalloc(CEIL(len, BITS_PER_LONG), sizeof(unsigned long), GFP_KERNEL);

	tiles = puzzle[lines - 1];
	for (i = 0; i < len; i++) {
		switch (buffer[i]) {
			case OPEN_TILE:
				bitmap_clear(tiles, i, 1);
				break;
			case TREE_TILE:
				bitmap_set(tiles, i, 1);
				break;
			default:
				return 1;
		}
	}

	return 0;
}

static ssize_t device_file_write(struct file *fp, const char __user *buffer, size_t len, loff_t *offset)
{
	const char *start = buffer;
	const char *end = start;

	while (end - buffer < len) {
		if (*end == '\n') {
			if (line_len == -1)
				line_len = end - start;
			
			if (line_len != (end - start)) {
				printk(KERN_WARNING "unexpected input; line lengths are not cohesive");
				return -EINVAL;
			}

			//printk(KERN_INFO "line: %.*s\n", (int) (end - start), start);

			if (append_input_line(start, end - start)) {
				printk(KERN_WARNING "invalid input; unexpected character in input");
				return -EINVAL;
			}

			start = end + 1;
		}

		end++;
	}

	return end - buffer;
}

static unsigned solve(int right, int down)
{
	unsigned trees_encountered = 0;

	size_t current_line = 0;
	size_t current_tile = 0;
	unsigned long *line;

	while ((current_line += down) < lines) {
		current_tile = (current_tile + right) % line_len;
		
		line = puzzle[current_line];
		
		if (test_bit(current_tile, line))
			trees_encountered++;
	}

	return trees_encountered;
}

static void solve_part1(void)
{
	unsigned trees_encountered = solve(3, 1);

	printk(KERN_INFO "[part 1]: encountered %u trees\n", trees_encountered);
}

static void solve_part2(void)
{
	int vectors[5][2] = {{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}};
	
	size_t i;
	int right, down;
	unsigned long long trees_encountered = 1;
	for (i = 0; i < 5; i++) {
		right = vectors[i][0];
		down = vectors[i][1];

		trees_encountered *= solve(right, down);
	}


	printk(KERN_INFO "[part 2]: encountered %llu trees\n", trees_encountered);
}

/**
 * Invoked when the device is close()'d. Solve the puzzle and release any resources.
 * */
static int device_release(struct inode *inode, struct file *file)
{
	size_t i;

	solve_part1();
	solve_part2();

	for (i = 0; i < lines; i++)
		kfree(puzzle[i]);

	kfree(puzzle);
	return 0;
}

/**
 * Kernel module entrypoint. Register character device '/dev/aoc2020d3'.
 * */
static int __init aoc2020_day3_kmod_init(void)
{
	struct device *p_dev;

	device_file_major_num = register_chrdev(0, device_name, &fops);
	
	if (device_file_major_num < 0) {
		printk(KERN_WARNING "aoc2020d3: failed to register character device; error code = %i\n", device_file_major_num);
		return device_file_major_num;
	}

	// create device /dev/aoc2020d3
	device_no = MKDEV(device_file_major_num, 0);
	p_class = class_create(THIS_MODULE, "aoc2020d3");
	if (IS_ERR(p_class)) {
		printk(KERN_WARNING "failed to create class");
		unregister_chrdev_region(device_no, 1);
		return -1;
	}
	
	p_dev = device_create(p_class, NULL, device_no, NULL, "aoc2020d3");
	if (IS_ERR(p_dev)) {
		printk(KERN_WARNING "failed to create device /dev/aoc2020d3\n");
		class_destroy(p_class);
		unregister_chrdev_region(device_no, 1);
		return -1;
	}
	
	return 0;
}

/**
 * Kernel module teardown. Destroy and unregister character device '/dev/aoc2020d3'.
 * */
static void __exit aoc2020_day3_kmod_exit(void)
{
	device_destroy(p_class, device_no);
	class_destroy(p_class);

	if (device_file_major_num >= 0)
		unregister_chrdev(device_file_major_num, device_name);
}

module_init(aoc2020_day3_kmod_init);
module_exit(aoc2020_day3_kmod_exit);

