/**
 * @file
 * @brief	HID Library - Generic USB backend.
 * @copyright	@parblock
 * Copyright (C):
 * - 2003-2016 -- Arnaud Quette (<aquette.dev@gmail.com>), for MGE UPS SYSTEMS and Eaton
 * - 2005      -- Peter Selinger (<selinger@users.sourceforge.net>)
 * - 2018      -- Daniele Pezzini (<hyouko@gmail.com>)
 *
 * This program is free software: you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 *      (at your option) any later version.
 *
 *      This program is distributed in the hope that it will be useful,
 *      but WITHOUT ANY WARRANTY; without even the implied warranty of
 *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *      GNU General Public License for more details.
 *
 *      You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *		@endparblock
 */

#ifndef NUT_LIBUSB_H_SEEN
#define NUT_LIBUSB_H_SEEN 1

#include "main.h"	/* for upsdrv_info_t */
#include "usb-common.h"	/* for USBDevice_t and USBDeviceMatcher_t */

/* libusb header file */
#ifdef WITH_LIBUSB_1_0
#include <libusb.h>
#endif
#ifdef WITH_LIBUSB_0_1
#include "libusb-compat-1.0.h"
#endif

#define LIBUSB_DEFAULT_INTERFACE        0
#define LIBUSB_DEFAULT_DESC_INDEX       0
#define LIBUSB_DEFAULT_HID_EP_IN        1
#define LIBUSB_DEFAULT_HID_EP_OUT       1

/** @brief USB communication subdriver description. */
extern upsdrv_info_t comm_upsdrv_info;

/** @brief Structure/type describing the USB communication routines.
 * @name: can be either "shut" for Serial HID UPS Transfer (from MGE) or "usb"
 */
typedef struct usb_communication_subdriver_s {
	const char	  *name;			/**< @brief Name of this subdriver. */
	const char	  *version;			/**< @brief Version of this subdriver. */
	void		 (*init)			/** @brief Initialise the communication subdriver.
							 *
							 * This function must be called before any other function this subdriver provides
							 * (except add_nutvars() and strerror()):
							 * it allocates any needed resource and initialise the communication subdriver.
							 *
							 * Initialisation is actually only done if not yet performed,
							 * or when deinit() has been called the same number of times as init().
							 *
							 * @warning This function calls exit() on fatal errors. */
	(
		void
	);
	void		 (*deinit)			/** @brief Deinitialise the communication subdriver.
							 *
							 * Call this function when done with the communication subdriver,
							 * so that it can release any resource previously allocated in init(),
							 * and perform any step needed to cleanly deinitialise the subdriver without leftovers.
							 *
							 * Deinitialisation is actually only done when deinit() has been called the same number of times as init().
							 *
							 * @note Any previously open()'d device should be close()'d before calling this function. */
	(
		void
	);
	int		 (*open)			/** @brief (Re)Open a device matching *matcher*.
							 *
							 * If *sdevp* refers to an already opened device, it is closed before attempting the reopening, if it safe to do so.
							 *
							 * If the opened device is not accepted by the caller (see *callback*),
							 * the next available device (if any) will be tried, until there are no more devices left.
							 *
							 * @note If no *callback* is provided, the opened device need not be a HID class device.
							 *
							 * @warning This function calls exit() on fatal errors.
							 *
							 * @return @ref LIBUSB_SUCCESS, with *curDevice* filled, on success,
							 * @return a @ref libusb_error "LIBUSB_ERROR" code, on errors. */
	(
		libusb_device_handle	**sdevp,		/**< [in,out]	storage location for the handle of the (already) opened device */
		USBDevice_t		 *curDevice,		/**<    [out]	@ref USBDevice_t that has to be populated on success and representing the opened device */
		USBDeviceMatcher_t	 *matcher,		/**< [in]	matcher that has to be matched by the opened device */
		int			  configuration,	/**< [in]	USB configuration that has to be set on the opened device:
								 *		either a non-negative value, or one of the @ref comm_config_sv "dedicated special values". */
		int			(*callback)		/**< [in]	@parblock
								 * (optional) function to tell whether the opened device is accepted by the caller or not
								 *
								 * **Returns**
								 * - 1, if the device is accepted,
								 * - 0, if not.
								 *
								 * **Parameters**
								 * - `[in]` **udev**: handle of the opened device
								 * - `[in]` **hd**: @ref USBDevice_t of the opened device (*curDevice*)
								 * - `[in]` **rdbuf**: report descriptor of the opened device
								 * - `[in]` **rdlen**: length of the report descriptor (*rdbuf* is guaranteed to be at least this size)
								 *		@endparblock */
		(
			libusb_device_handle	*udev,
			USBDevice_t		*hd,
			unsigned char		*rdbuf,
			int			 rdlen
		)
	);
	void		 (*close)			/** @brief Close the opened device *sdev* refers to. */
	(
		libusb_device_handle	*sdev			/**< [in] handle of an opened device */
	);
	int		 (*get_report)			/** @brief Retrieve a HID report from a device.
							 * @warning This function calls exit() on fatal errors.
							 * @return length of the retrieved data, on success,
							 * @return a @ref libusb_error "LIBUSB_ERROR" code, on errors. */
	(
		libusb_device_handle	*sdev,			/**< [in] handle of an already opened device */
		int			 ReportId,		/**< [in] ID of the report that has to be retrieved */
		unsigned char		*raw_buf,		/**< [out] storage location for the retrieved data */
		int			 ReportSize		/**< [in] size of the report (*raw_buf* should be at least this size) */
	);
	int		 (*set_report)			/** @brief Set a HID report in a device.
							 * @warning This function calls exit() on fatal errors.
							 * @return the number of bytes sent to the device, on success,
							 * @return a @ref libusb_error "LIBUSB_ERROR" code, on errors. */
	(
		libusb_device_handle	*sdev,			/**< [in] handle of an already opened device */
		int			 ReportId,		/**< [in] ID of the report that has to be set */
		unsigned char		*raw_buf,		/**< [in] data that has to be set */
		int			 ReportSize		/**< [in] size of the report (*raw_buf* should be at least this size) */
	);
	int		 (*get_string)			/** @brief Retrieve a string descriptor from a device.
							 * @warning This function calls exit() on fatal errors.
							 * @return the number of bytes read and stored in *buf*, on success,
							 * @return a @ref libusb_error "LIBUSB_ERROR" code, on errors. */
	(
		libusb_device_handle	*sdev,			/**< [in] handle of an already opened device */
		int			 StringIdx,		/**< [in] index of the descriptor to retrieve */
		char			*buf,			/**< [out] storage location for the retrieved string */
		size_t			 buflen			/**< [in] size of *buf* */
	);
	int		 (*get_interrupt)		/** @brief Retrieve data from an interrupt endpoint of a device.
							 * @warning This function calls exit() on fatal errors.
							 * @return the number of bytes read and stored in *buf*, on success,
							 * @return a @ref libusb_error "LIBUSB_ERROR" code, on errors. */
	(
		libusb_device_handle	*sdev,			/**< [in] handle of an already opened device */
		unsigned char		*buf,			/**< [out] storage location for the retrieved data */
		int			 bufsize,		/**< [in] size of *buf* */
		int			 timeout		/**< [in] allowed timeout (ms) for the operation */
	);
	const char	*(*strerror)			/** @brief Return a constant string with a short description of *errcode*.
							 * @return a short description of *errcode*. */
	(
		enum libusb_error	errcode			/**< [in] the @ref libusb_error code whose description is desired */
	);
	void		 (*add_nutvars)			/** @brief Add USB-related driver variables with addvar() and dstate_setinfo(). */
	(
		void
	);

	/* Used for Powervar UPS or similar cases to make sure
	 * we use the right interface in the Composite device
	 */
	int hid_rep_index;
	/* All devices use HID descriptor at index 0.
	 * However, some UPS like newer Eaton units have
	 * a light HID descriptor at index 0, and
	 * the full version is at index 1 (in which
	 * case, bcdDevice == 0x0202)
	 */
	int hid_desc_index;
	int hid_ep_in;			/* Input interrupt endpoint. Default is 1	*/
	int hid_ep_out;			/* Output interrupt endpoint. Default is 1	*/
} usb_communication_subdriver_t;

/** @brief Special values for usb_communication_subdriver_t::open()'s *configuration* argument. */
enum comm_config_sv {
	COMM_CONFIG_SKIP	= -2,			/**< Skip the USB configuration setting. */
	COMM_CONFIG_RESET	= -1			/**< Try to put the device back into an 'unconfigured' state. */
};

/** @brief Actual USB communication subdriver. */
extern usb_communication_subdriver_t	usb_subdriver;

#endif /* NUT_LIBUSB_H_SEEN */
