import "performance"
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.services

Item {
    id: root

    implicitWidth: placeholder.active ? Tokens.sizes.dashboard.perfPlaceholderWidth : content.implicitWidth
    implicitHeight: placeholder.active ? placeholder.implicitHeight + Tokens.padding.extraLarge * 2 : content.implicitHeight

    Loader {
        id: placeholder

        anchors.centerIn: parent
        active: !Config.dashboard.performance.showCpu && !(Config.dashboard.performance.showGpu && (Gpu.type !== GpuType.None || AmdGpu.hasGpu)) && !Config.dashboard.performance.showMemory && !Config.dashboard.performance.showStorage && !Config.dashboard.performance.showNetwork && !(UPower.displayDevice.isLaptopBattery && Config.dashboard.performance.showBattery)
        asynchronous: true

        sourceComponent: ColumnLayout {
            spacing: Tokens.spacing.medium

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "tune"
                fontStyle: Tokens.font.icon.builders.extraLarge.scale(2).build()
                color: Colours.palette.m3onSurfaceVariant
            }

            StyledText {
                Layout.topMargin: -Tokens.spacing.small
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("No widgets enabled")
                font: Tokens.font.title.large
                color: Colours.palette.m3onSurface
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Enable widgets in the dashboard settings")
                font: Tokens.font.body.small
                color: Colours.palette.m3onSurfaceVariant
            }
        }
    }

    RowLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spacing.medium
        visible: !placeholder.active

        ColumnLayout {
            id: mainColumn

            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            RowLayout {
                spacing: Tokens.spacing.medium
                visible: cpuCard.active || amdGpuCard.active || gpuCard.active

                WrappedLoader {
                    id: cpuCard

                    active: Config.dashboard.performance.showCpu

                    sourceComponent: HeroCard {
                        icon: "memory"
                        label: qsTr("CPU")
                        subLabel: Cpu.name
                        usage: Cpu.percentage
                        temperature: Cpu.temperature
                        accent: Colours.palette.m3primary

                        ServiceRef {
                            service: Cpu
                        }
                    }
                }

                WrappedLoader {
                    id: amdGpuCard

                    active: Config.dashboard.performance.showGpu && AmdGpu.hasGpu

                    sourceComponent: HeroCard {
                        icon: "desktop_windows"
                        label: Gpu.type !== GpuType.None ? qsTr("iGPU") : qsTr("GPU")
                        subLabel: AmdGpu.name
                        usage: AmdGpu.percentage
                        temperature: AmdGpu.temperature
                        accent: Colours.palette.m3tertiary

                        Component.onCompleted: AmdGpu.addRef()
                        Component.onDestruction: AmdGpu.removeRef()
                    }
                }

                WrappedLoader {
                    id: gpuCard

                    active: Config.dashboard.performance.showGpu && Gpu.type !== GpuType.None

                    sourceComponent: HeroCard {
                        icon: "developer_board"
                        label: AmdGpu.hasGpu ? qsTr("dGPU") : qsTr("GPU")
                        subLabel: Gpu.name
                        usage: Gpu.percentage
                        temperature: Gpu.temperature
                        accent: Colours.palette.m3secondary

                        ServiceRef {
                            service: Gpu
                        }
                    }
                }
            }

            RowLayout {
                spacing: Tokens.spacing.medium
                visible: storageCard.active || networkCard.active || memoryCard.active

                WrappedLoader {
                    id: storageCard

                    active: Config.dashboard.performance.showStorage
                    sourceComponent: StorageCard {}
                }

                WrappedLoader {
                    id: networkCard

                    active: Config.dashboard.performance.showNetwork
                    sourceComponent: NetworkCard {}
                }

                WrappedLoader {
                    id: memoryCard

                    active: Config.dashboard.performance.showMemory
                    sourceComponent: MemoryCard {}
                }
            }
        }

        WrappedLoader {
            Layout.fillWidth: false
            active: UPower.displayDevice.isLaptopBattery && Config.dashboard.performance.showBattery
            sourceComponent: BatteryTank {}
        }
    }

    component WrappedLoader: Loader {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: active
    }
}
