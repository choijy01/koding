package j_stack_template

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"fmt"
	"io"

	"github.com/go-openapi/runtime"

	strfmt "github.com/go-openapi/strfmt"

	"koding/remoteapi/models"
)

// JStackTemplateSomeReader is a Reader for the JStackTemplateSome structure.
type JStackTemplateSomeReader struct {
	formats strfmt.Registry
}

// ReadResponse reads a server response into the received o.
func (o *JStackTemplateSomeReader) ReadResponse(response runtime.ClientResponse, consumer runtime.Consumer) (interface{}, error) {
	switch response.Code() {

	case 200:
		result := NewJStackTemplateSomeOK()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return result, nil

	case 401:
		result := NewJStackTemplateSomeUnauthorized()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return nil, result

	default:
		return nil, runtime.NewAPIError("unknown error", response, response.Code())
	}
}

// NewJStackTemplateSomeOK creates a JStackTemplateSomeOK with default headers values
func NewJStackTemplateSomeOK() *JStackTemplateSomeOK {
	return &JStackTemplateSomeOK{}
}

/*JStackTemplateSomeOK handles this case with default header values.

Request processed successfully
*/
type JStackTemplateSomeOK struct {
	Payload *models.DefaultResponse
}

func (o *JStackTemplateSomeOK) Error() string {
	return fmt.Sprintf("[POST /remote.api/JStackTemplate.some][%d] jStackTemplateSomeOK  %+v", 200, o.Payload)
}

func (o *JStackTemplateSomeOK) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(models.DefaultResponse)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}

// NewJStackTemplateSomeUnauthorized creates a JStackTemplateSomeUnauthorized with default headers values
func NewJStackTemplateSomeUnauthorized() *JStackTemplateSomeUnauthorized {
	return &JStackTemplateSomeUnauthorized{}
}

/*JStackTemplateSomeUnauthorized handles this case with default header values.

Unauthorized request
*/
type JStackTemplateSomeUnauthorized struct {
	Payload *models.UnauthorizedRequest
}

func (o *JStackTemplateSomeUnauthorized) Error() string {
	return fmt.Sprintf("[POST /remote.api/JStackTemplate.some][%d] jStackTemplateSomeUnauthorized  %+v", 401, o.Payload)
}

func (o *JStackTemplateSomeUnauthorized) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(models.UnauthorizedRequest)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}
