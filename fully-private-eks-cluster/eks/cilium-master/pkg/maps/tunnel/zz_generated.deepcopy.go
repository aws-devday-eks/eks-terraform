//go:build !ignore_autogenerated
// +build !ignore_autogenerated

// SPDX-License-Identifier: Apache-2.0
// Copyright Authors of Cilium

// Code generated by deepcopy-gen. DO NOT EDIT.

package tunnel

import (
	bpf "github.com/cilium/cilium/pkg/bpf"
)

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *TunnelEndpoint) DeepCopyInto(out *TunnelEndpoint) {
	*out = *in
	in.EndpointKey.DeepCopyInto(&out.EndpointKey)
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new TunnelEndpoint.
func (in *TunnelEndpoint) DeepCopy() *TunnelEndpoint {
	if in == nil {
		return nil
	}
	out := new(TunnelEndpoint)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyMapKey is an autogenerated deepcopy function, copying the receiver, creating a new bpf.MapKey.
func (in *TunnelEndpoint) DeepCopyMapKey() bpf.MapKey {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyMapValue is an autogenerated deepcopy function, copying the receiver, creating a new bpf.MapValue.
func (in *TunnelEndpoint) DeepCopyMapValue() bpf.MapValue {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}
