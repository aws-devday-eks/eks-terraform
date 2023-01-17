package ecs

//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
//
// Code generated by Alibaba Cloud SDK Code Generator.
// Changes may cause incorrect behavior and will be lost if the code is regenerated.

// Report is a nested struct in ecs response
type Report struct {
	ResourceId   string  `json:"ResourceId" xml:"ResourceId"`
	ResourceType string  `json:"ResourceType" xml:"ResourceType"`
	MetricSetId  string  `json:"MetricSetId" xml:"MetricSetId"`
	StartTime    string  `json:"StartTime" xml:"StartTime"`
	EndTime      string  `json:"EndTime" xml:"EndTime"`
	ReportId     string  `json:"ReportId" xml:"ReportId"`
	Status       string  `json:"Status" xml:"Status"`
	CreationTime string  `json:"CreationTime" xml:"CreationTime"`
	FinishedTime string  `json:"FinishedTime" xml:"FinishedTime"`
	Severity     string  `json:"Severity" xml:"Severity"`
	Issues       []Issue `json:"Issues" xml:"Issues"`
}
